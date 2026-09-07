import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/payment_service.dart';
import '../services/razorpay_service.dart';

class CheckoutDialog extends StatefulWidget {
  final SubscriptionPlan plan;
  const CheckoutDialog({super.key, required this.plan});

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardController = TextEditingController(text: '4242 •••• •••• 4242');
  final _expController = TextEditingController(text: '12/28');
  final _cvcController = TextEditingController(text: '888');
  final _promoController = TextEditingController();

  double _finalPrice = 0.0;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _finalPrice = widget.plan.price;
  }

  @override
  void dispose() {
    _cardController.dispose();
    _expController.dispose();
    _cvcController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  void _onPromoChanged(String code) {
    setState(() {
      _finalPrice = PaymentService.applyPromoCode(code, widget.plan.price);
    });
  }

  Future<void> _payWithRazorpay() async {
    setState(() => _processing = true);

    final success = await RazorpayPaymentService().openRazorpayCheckout(
      planId: widget.plan.id,
      planTitle: widget.plan.title,
      priceInr: _finalPrice,
      userEmail: 'athlete@veltrixsports.com',
      userPhone: '9876543210',
    );

    if (mounted) {
      setState(() => _processing = false);
      if (success) {
        Navigator.pop(context, true);
        showFeatureMessage(
          context,
          'Secure checkout opened. Your subscription activates after payment verification.',
        );
      }
    }
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _processing = true);

    try {
      final success = await PaymentService.processPayment(
        plan: widget.plan,
        cardNumber: _cardController.text.trim(),
        promoCode: _promoController.text.trim(),
      );

      if (mounted && success) {
        Navigator.pop(context, true);
        showFeatureMessage(
          context,
          'Welcome to ${widget.plan.title}! Your account is now active.',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final discountApplied = _finalPrice < widget.plan.price;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.lock_outline, color: Colors.green, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Checkout — ${widget.plan.title}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: navy,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kDebugMode)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange, width: 0.8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.science_outlined,
                        color: Colors.orange,
                        size: 13,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'DEMO MODE — payments require backend verification',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              Semantics(
                label:
                    'Total price: ${_finalPrice.toStringAsFixed(0)} Indian rupees',
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: navy.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: navy.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.plan.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: navy,
                            ),
                          ),
                          Text(
                            '/${widget.plan.period}',
                            style: const TextStyle(color: muted, fontSize: 12),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (discountApplied)
                            Text(
                              '\u20b9${widget.plan.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: muted,
                                fontSize: 12,
                              ),
                            ),
                          Text(
                            '\u20b9${_finalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: navy,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Razorpay Quick Option
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _processing ? null : _payWithRazorpay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0c2340),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: lime,
                    size: 20,
                  ),
                  label: const Text(
                    'Pay via Razorpay (UPI, GPay, Card, NetBanking)',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'OR DIRECT CARD',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: muted,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _cardController,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expController,
                      decoration: const InputDecoration(
                        labelText: 'Expires (MM/YY)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return 'Required';
                        if (!RegExp(
                          r'^(0[1-9]|1[0-2])\/\d{2}$',
                        ).hasMatch(val.trim())) {
                          return 'Use MM/YY';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _cvcController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'CVC',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return 'Required';
                        if (!RegExp(r'^\d{3,4}$').hasMatch(val.trim())) {
                          return '3-4 digits';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _promoController,
                onChanged: _onPromoChanged,
                decoration: InputDecoration(
                  labelText: 'Promo Code',
                  hintText: 'e.g. ATHLETE20',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.card_giftcard),
                  suffixIcon:
                      discountApplied
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                ),
              ),
              if (discountApplied) ...[
                const SizedBox(height: 6),
                const Text(
                  'Promo code applied successfully!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _processing ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        Semantics(
          label:
              'Pay ${_finalPrice.toStringAsFixed(0)} Indian rupees for ${widget.plan.title}',
          button: true,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: lime,
              foregroundColor: navy,
            ),
            onPressed: _processing ? null : _pay,
            child:
                _processing
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text(
                      _finalPrice == 0
                          ? 'Activate Free Access'
                          : 'Pay \u20b9${_finalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
          ),
        ),
      ],
    );
  }
}
