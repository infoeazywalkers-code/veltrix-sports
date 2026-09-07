import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'payment_backend_service.dart';

class RazorpayPaymentService extends ChangeNotifier {
  static final RazorpayPaymentService _instance =
      RazorpayPaymentService._internal();
  factory RazorpayPaymentService() => _instance;
  RazorpayPaymentService._internal();

  Razorpay? _razorpay;
  bool _isProcessing = false;
  String? _lastPaymentId;
  String? _lastError;
  String? _pendingOrderId;

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
    notifyListeners();

    final backend = PaymentBackendService();
    late final PaymentOrder order;
    try {
      order = await backend.createOrder(planId: planId);
      _pendingOrderId = order.orderId;
    } catch (error) {
      _isProcessing = false;
      _lastError = 'Unable to create a secure payment order: $error';
      notifyListeners();
      return false;
    }

    final options = {
      'key': order.keyId,
      'amount': order.amountPaise,
      'order_id': order.orderId,
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
      'notes': {'plan_id': planId},
    };

    if (kIsWeb) {
      _isProcessing = false;
      _lastError =
          'Razorpay web checkout must be handled through a verified backend order.';
      notifyListeners();
      return false;
    }

    try {
      if (_razorpay == null) initialize();
      _razorpay?.open(options);
      return true;
    } catch (e) {
      _isProcessing = false;
      _lastError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final paymentId =
        response.paymentId ??
        'pay_success_${DateTime.now().millisecondsSinceEpoch}';

    try {
      await PaymentBackendService().verifyPayment(
        orderId: response.orderId ?? _pendingOrderId ?? '',
        paymentId: paymentId,
        signature: response.signature ?? '',
      );
      _lastPaymentId = paymentId;
      _lastError = null;
    } catch (error) {
      _lastError = 'Payment received but verification failed. Contact support with $paymentId.';
    } finally {
      _isProcessing = false;
    }
    notifyListeners();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _isProcessing = false;
    _lastError = response.message ?? 'Payment failed or cancelled by user.';
    notifyListeners();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (kDebugMode) {
      debugPrint('[Razorpay External Wallet] ${response.walletName}');
    }
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }
}
