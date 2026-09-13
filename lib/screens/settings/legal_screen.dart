import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// Displays the genuine Veltrix Sports legal documents.
///
/// Pass [isTerms] = true for the Terms of Service, false for the Privacy
/// Policy. Linked from [HelpSupportScreen]'s Legal section.
class LegalScreen extends StatelessWidget {
  final bool isTerms;

  const LegalScreen({super.key, required this.isTerms});

  @override
  Widget build(BuildContext context) {
    final sections = isTerms ? _termsSections : _privacySections;
    return Scaffold(
      appBar: AppBar(
        title: Text(isTerms ? 'Terms of Service' : 'Privacy Policy'),
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            isTerms ? 'Terms of Service' : 'Privacy Policy',
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : navy),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last updated: September 2026',
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF78909C)
                  : muted),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          for (final section in sections) ...[
            _LegalSection(title: section.$1, body: section.$2),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  final String title;
  final String body;

  const _LegalSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : navy),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: TextStyle(
            color: (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFFB0BEC5)
                : ink),
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

const List<(String, String)> _termsSections = [
  (
    '1. Acceptance of Terms',
    'By creating a Veltrix Sports account or using the app, you agree to these '
        'Terms of Service and to our Privacy Policy. If you do not agree, do not '
        'use the service. We may update these terms from time to time; continued '
        'use after changes take effect constitutes acceptance of the revised terms.',
  ),
  (
    '2. Accounts & Eligibility',
    'You must be at least 13 years old (or the minimum age required in your '
        'country) to use Veltrix Sports. You are responsible for keeping your '
        'sign-in credentials confidential and for all activity under your account. '
        'You agree to provide accurate profile information and to notify us of any '
        'unauthorised use of your account.',
  ),
  (
    '3. Subscriptions & Billing',
    'Veltrix Premium is billed on a recurring subscription basis. Payments are '
        'processed securely through Razorpay; we never store your full card or '
        'bank details on our servers. Prices are shown before purchase and include '
        'applicable taxes. You can cancel at any time from the subscription '
        'settings — cancellation takes effect at the end of the current billing '
        'period. Refunds are handled case by case in line with the applicable app '
        'store and Razorpay policies.',
  ),
  (
    '4. Acceptable Use',
    'You agree not to misuse the service: no uploading unlawful or infringing '
        'content, no attempting to disrupt or reverse-engineer the app, no '
        'harassing other athletes or coaches, and no using training data of other '
        'users for any purpose outside the app. We may suspend or terminate '
        'accounts that violate these terms or applicable law.',
  ),
  (
    '5. Health & Fitness Disclaimer',
    'Veltrix Sports provides training plans, performance metrics, and coaching '
        'insights for informational purposes only. They are NOT medical advice. '
        'Always consult a qualified healthcare professional before starting or '
        'changing an exercise programme, especially if you have a medical '
        'condition, injury, or are pregnant. Stop training and seek medical help '
        'if you feel pain, dizziness, or chest discomfort. You train at your own risk.',
  ),
  (
    '6. Intellectual Property',
    'The Veltrix Sports app, branding, training content, and software are owned '
        'by Veltrix Sports and protected by intellectual-property laws. You '
        'receive a limited, non-transferable licence to use the app for personal, '
        'non-commercial training purposes. Your own workout data remains yours; '
        'by uploading content you grant us the licence needed to store, display, '
        'and analyse it to operate the service.',
  ),
  (
    '7. Limitation of Liability',
    'To the maximum extent permitted by law, Veltrix Sports is not liable for '
        'indirect, incidental, or consequential damages, including injuries '
        'sustained while training, loss of data, or loss of performance progress. '
        'Our total liability for any claim is limited to the amount you paid for '
        'the service in the 12 months before the claim arose.',
  ),
  (
    '8. Contact Us',
    'Questions about these terms? Reach us at support@veltrixsports.com and we '
        'will respond as soon as possible. These terms are governed by the laws '
        'of India, and disputes will be subject to the jurisdiction of the courts '
        'of Mumbai, Maharashtra.',
  ),
];

const List<(String, String)> _privacySections = [
  (
    '1. Data We Collect',
    'We collect the minimum data needed to run your training experience: account '
        'details (name, email, profile photo), training data (workouts, plans, '
        'performance metrics, preferences), and technical data (device type, app '
        'version, crash reports). Optional data such as weight, FTP, VO2 max, and '
        'heart-rate zones is collected only when you provide it.',
  ),
  (
    '2. Firebase & Firestore Usage',
    'We use Google Firebase services to operate the app. Firebase Authentication '
        'manages sign-in, Cloud Firestore stores your profile, workouts, and plans, '
        'and Firebase Crashlytics and Analytics help us fix bugs and understand '
        'feature usage. This data is processed under Google\'s data-processing '
        'terms and may be stored on Google\'s secure cloud infrastructure.',
  ),
  (
    '3. Health & Device Data',
    'With your permission, we read workout and sensor data from Apple HealthKit, '
        'Health Connect, and connected Bluetooth devices (heart-rate monitors, '
        'power meters, watches). This data is used only to display and analyse '
        'your training. You can revoke access at any time from your device '
        'settings or by disconnecting the device in the app.',
  ),
  (
    '4. Payments via Razorpay',
    'Premium subscriptions are processed by Razorpay, our payment partner. '
        'Payment details you enter are transmitted directly to Razorpay under '
        'their privacy policy; Veltrix Sports does not see or store your full '
        'card numbers or bank credentials. We retain only the transaction status '
        'needed to manage your subscription.',
  ),
  (
    '5. Data Sharing',
    'We do not sell your personal data. We share data only with (a) service '
        'providers that help us operate the app (Firebase, Razorpay) under strict '
        'contractual safeguards, (b) coaches you explicitly connect with, limited '
        'to the training data needed for coaching, and (c) authorities when '
        'required by law.',
  ),
  (
    '6. Data Retention',
    'We keep your account and training data for as long as your account is '
        'active so your history and progress remain available. Backup copies may '
        'persist for a limited period afterwards. Anonymised, aggregated '
        'statistics that cannot identify you may be retained for product '
        'improvement.',
  ),
  (
    '7. Your Rights & Account Deletion',
    'You can access, correct, or export your data at any time, and you can '
        'request deletion of your account and associated personal data by going '
        'to Profile > Settings > Delete Account or by emailing '
        'support@veltrixsports.com with the subject "Delete my account". We will '
        'confirm deletion within 30 days, except for data we must retain for '
        'legal or billing-record purposes.',
  ),
  (
    '8. Contact Us',
    'For privacy questions or requests, contact support@veltrixsports.com. We '
        'aim to respond to all privacy requests within 30 days. If you believe '
        'your concern has not been addressed, you may lodge a complaint with '
        'your local data-protection authority.',
  ),
];
