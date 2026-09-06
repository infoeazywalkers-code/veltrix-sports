import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'payment_service.dart';
import 'analytics_service.dart';
import 'razorpay_webhook_service.dart';

class RazorpayPaymentService extends ChangeNotifier {
  static final RazorpayPaymentService _instance =
      RazorpayPaymentService._internal();
  factory RazorpayPaymentService() => _instance;
  RazorpayPaymentService._internal();

  Razorpay? _razorpay;
  bool _isProcessing = false;
  String? _lastPaymentId;
  String? _lastError;
  String? _pendingPlanId;

  bool get isProcessing => _isProcessing;
  String? get lastPaymentId => _lastPaymentId;
  String? get lastError => _lastError;

  void initialize() {
    if (kIsWeb) return;
    try {
      _razorpay = Razorpay();
      _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    } catch (e) {
      if (kDebugMode) debugPrint('[Razorpay Init Error] $e');
    }
  }

  Future<bool> openRazorpayCheckout({
    required String planId,
    required String planTitle,
    required double priceInr,
    required String userEmail,
    required String userPhone,
  }) async {
    _isProcessing = true;
    _lastError = null;
    _pendingPlanId = planId;
    notifyListeners();

    final amountPaise = (priceInr * 100).toInt();

    final options = {
      'key': const String.fromEnvironment(
        'RAZORPAY_KEY_ID',
        defaultValue: 'rzp_test_VeltrixSports2026',
      ),
      'amount': amountPaise,
      'name': 'Veltrix Sports Premium',
      'description': '$planTitle Subscription',
      'prefill': {
        'contact': userPhone.isNotEmpty ? userPhone : '9876543210',
        'email': userEmail.isNotEmpty ? userEmail : 'athlete@veltrixsports.com',
      },
      'theme': {'color': '#102a43'},
      'external': {
        'wallets': ['paytm', 'phonepe', 'gpay'],
      },
    };

    if (kIsWeb) {
      // Simulated Razorpay Web checkout for web client test environments
      await Future.delayed(const Duration(milliseconds: 1500));
      final simulatedPaymentId =
          'pay_web_${DateTime.now().millisecondsSinceEpoch}';
      await _processSuccessfulUpgrade(planId, simulatedPaymentId);
      return true;
    }

    try {
      if (_razorpay == null) initialize();
      _razorpay?.open(options);
      return true;
    } catch (e) {
      _isProcessing = false;
      _pendingPlanId = null;
      _lastError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final paymentId =
        response.paymentId ??
        'pay_success_${DateTime.now().millisecondsSinceEpoch}';
    final orderId =
        response.orderId ??
        'order_sim_${DateTime.now().millisecondsSinceEpoch}';
    final signature = response.signature ?? '';

    if (signature.isNotEmpty) {
      final isVerified = RazorpayWebhookVerificationService.verifySignature(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );
      if (!isVerified) {
        _isProcessing = false;
        _pendingPlanId = null;
        _lastError =
            'Payment signature verification failed. '
            'Please contact support if you were charged.';
        notifyListeners();
        return;
      }
    } else if (!kDebugMode) {
      // In release mode, reject payments without a signature entirely
      _isProcessing = false;
      _pendingPlanId = null;
      _lastError =
          'Payment response missing signature. '
          'Please contact support if you were charged.';
      notifyListeners();
      return;
    }

    _lastPaymentId = paymentId;
    await _processSuccessfulUpgrade(_pendingPlanId ?? 'monthly_pro', paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _isProcessing = false;
    _pendingPlanId = null;
    _lastError = response.message ?? 'Payment failed or cancelled by user.';
    notifyListeners();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (kDebugMode) {
      debugPrint('[Razorpay External Wallet] ${response.walletName}');
    }
  }

  Future<void> _processSuccessfulUpgrade(
    String planId,
    String paymentId,
  ) async {
    try {
      final targetPlan = PaymentService.availablePlans.firstWhere(
        (p) => p.id == planId,
        orElse: () => PaymentService.availablePlans.first,
      );
      await PaymentService.processPayment(
        plan: targetPlan,
        cardNumber: 'RAZORPAY_$paymentId',
        promoCode: 'RAZORPAY',
      );
      await AnalyticsService.logSubscriptionPurchased(planId, targetPlan.price);
    } catch (e) {
      if (kDebugMode) debugPrint('[Razorpay Upgrade Error] $e');
    } finally {
      _isProcessing = false;
      _pendingPlanId = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }
}
