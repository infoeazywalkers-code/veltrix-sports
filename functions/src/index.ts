import { createHmac } from 'node:crypto';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

initializeApp();
const db = getFirestore();
const razorpayKeyId = defineSecret('RAZORPAY_KEY_ID');
const razorpayKeySecret = defineSecret('RAZORPAY_KEY_SECRET');

const PLANS: Record<string, { amountPaise: number; tier: string }> = {
  monthly_pro: { amountPaise: 49900, tier: 'monthly_pro' },
  annual_pro: { amountPaise: 39900, tier: 'annual_pro' },
  coach_pro: { amountPaise: 149900, tier: 'coach_pro' },
};

function requireUser(request: { auth?: { uid: string } | null }): string {
  if (!request.auth?.uid) throw new HttpsError('unauthenticated', 'Sign in before paying.');
  return request.auth.uid;
}

async function razorpay(path: string, init: RequestInit = {}): Promise<any> {
  const credentials = Buffer.from(`${razorpayKeyId.value()}:${razorpayKeySecret.value()}`).toString('base64');
  const response = await fetch(`https://api.razorpay.com/v1${path}`, {
    ...init,
    headers: { authorization: `Basic ${credentials}`, 'content-type': 'application/json', ...(init.headers ?? {}) },
  });
  if (!response.ok) throw new HttpsError('internal', 'Razorpay rejected the request.');
  return response.json();
}

export const createRazorpayOrder = onCall(
  { secrets: [razorpayKeyId, razorpayKeySecret], enforceAppCheck: true },
  async (request) => {
    const userId = requireUser(request);
    const planId = request.data?.planId as string | undefined;
    const plan = planId ? PLANS[planId] : undefined;
    if (!plan) throw new HttpsError('invalid-argument', 'Unknown subscription plan.');

    const order = await razorpay('/orders', {
      method: 'POST',
      body: JSON.stringify({ amount: plan.amountPaise, currency: 'INR', receipt: `veltrix_${userId}_${Date.now()}`, notes: { userId, planId } }),
    });
    await db.collection('payment_orders').doc(order.id).set({ userId, planId, amountPaise: plan.amountPaise, status: 'created', createdAt: FieldValue.serverTimestamp() });
    return { orderId: order.id, amountPaise: plan.amountPaise, keyId: razorpayKeyId.value() };
  },
);

export const verifyRazorpayPayment = onCall(
  { secrets: [razorpayKeyId, razorpayKeySecret], enforceAppCheck: true },
  async (request) => {
    const userId = requireUser(request);
    const { orderId, paymentId, signature } = request.data ?? {};
    if (![orderId, paymentId, signature].every((value) => typeof value === 'string' && value.length > 0)) {
      throw new HttpsError('invalid-argument', 'Payment verification data is incomplete.');
    }
    const orderRef = db.collection('payment_orders').doc(orderId);
    const orderSnapshot = await orderRef.get();
    const order = orderSnapshot.data();
    if (!order || order.userId !== userId || order.status === 'verified') throw new HttpsError('permission-denied', 'Payment order is invalid.');

    const expected = createHmac('sha256', razorpayKeySecret.value()).update(`${orderId}|${paymentId}`).digest('hex');
    if (expected !== signature) throw new HttpsError('invalid-argument', 'Payment signature is invalid.');
    const payment = await razorpay(`/payments/${paymentId}`);
    if (payment.order_id !== orderId || payment.amount !== order.amountPaise || !['captured', 'authorized'].includes(payment.status)) {
      throw new HttpsError('failed-precondition', 'Payment amount or status could not be verified.');
    }

    const userRef = db.collection('users').doc(userId);
    await db.runTransaction(async (transaction) => {
      transaction.update(orderRef, { status: 'verified', paymentId, verifiedAt: FieldValue.serverTimestamp() });
      transaction.set(userRef, { isPremium: true, subscriptionTier: order.planId, subscriptionRenewsAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    });
    return { verified: true };
  },
);

export const registerForEvent = onCall(
  { enforceAppCheck: true },
  async (request) => {
    const userId = requireUser(request);
    const eventId = request.data?.eventId as string | undefined;
    if (!eventId) throw new HttpsError('invalid-argument', 'Event is required.');
    const eventRef = db.collection('events').doc(eventId);
    const ticketRef = db.collection('tickets').doc(`${eventId}_${userId}`);
    let ticketData: Record<string, any> = {};
    await db.runTransaction(async (transaction) => {
      const [eventSnapshot, existingTicket] = await Promise.all([transaction.get(eventRef), transaction.get(ticketRef)]);
      if (existingTicket.exists) {
        ticketData = existingTicket.data()!;
        return;
      }
      const event = eventSnapshot.data();
      if (!event) throw new HttpsError('not-found', 'Event not found.');
      const capacity = Number(event.capacity ?? 0);
      const registeredCount = Number(event.registeredCount ?? 0);
      if (capacity > 0 && registeredCount >= capacity) throw new HttpsError('resource-exhausted', 'This event is full.');
      ticketData = { id: ticketRef.id, eventId, eventTitle: event.title, userId, status: 'confirmed', qrPayload: `veltrix:${ticketRef.id}`, createdAt: FieldValue.serverTimestamp() };
      transaction.set(ticketRef, ticketData);
      transaction.update(eventRef, { registeredCount: registeredCount + 1 });
    });
    return { ...ticketData!, createdAt: undefined };
  },
);
