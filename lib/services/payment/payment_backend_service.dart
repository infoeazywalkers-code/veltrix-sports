import 'package:cloud_functions/cloud_functions.dart';

class PaymentBackendService {
  final FirebaseFunctions _functions;

  PaymentBackendService({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  Future<PaymentOrder> createOrder({required String planId}) async {
    final callable = _functions.httpsCallable('createRazorpayOrder');
    final result = await callable.call({'planId': planId});
    final data = Map<String, dynamic>.from(result.data as Map);
    return PaymentOrder(
      orderId: data['orderId'] as String,
      amountPaise: (data['amountPaise'] as num).toInt(),
      keyId: data['keyId'] as String,
    );
  }

  Future<void> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final callable = _functions.httpsCallable('verifyRazorpayPayment');
    await callable.call({
      'orderId': orderId,
      'paymentId': paymentId,
      'signature': signature,
    });
  }
}

class PaymentOrder {
  final String orderId;
  final int amountPaise;
  final String keyId;

  const PaymentOrder({
    required this.orderId,
    required this.amountPaise,
    required this.keyId,
  });
}
