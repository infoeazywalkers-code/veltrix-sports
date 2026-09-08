import 'package:flutter/material.dart';
import '../constants.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('FAQ', [
            _buildFaqItem(
              'How do I connect my heart rate monitor?',
              'Go to Settings > Devices > Connect Device. Make sure Bluetooth is enabled on your phone.',
            ),
            _buildFaqItem(
              'How do I change my training plan?',
              'Go to Plans > Browse Plans to find a new plan, or contact your coach for a custom plan.',
            ),
            _buildFaqItem(
              'How do I update my profile?',
              'Go to Profile > Edit Profile to update your name, sport, and other details.',
            ),
            _buildFaqItem(
              'How do I cancel my subscription?',
              'Go to Settings > Subscription > Manage Subscription to cancel.',
            ),
            _buildFaqItem(
              'Is my data private?',
              'Yes. Your data is encrypted and stored securely. You can control visibility in Settings > Privacy.',
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Contact Us', [
            _buildContactTile(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@veltrixsports.com',
              onTap:
                  () => _showContactInfo(
                    context,
                    'Email Support',
                    'support@veltrixsports.com',
                  ),
            ),
            _buildContactTile(
              icon: Icons.report_outlined,
              title: 'Report a Bug',
              subtitle: 'Tell us about an issue',
              onTap:
                  () => _showContactInfo(
                    context,
                    'Report a Bug',
                    'bugs@veltrixsports.com',
                  ),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Legal', [
            _buildContactTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () => _showLegalPlaceholder(context, 'Terms of Service'),
            ),
            _buildContactTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => _showLegalPlaceholder(context, 'Privacy Policy'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: navy,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 16),
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Text(answer, style: TextStyle(color: Colors.grey[600], height: 1.5)),
      ],
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: blue),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showContactInfo(BuildContext context, String title, String email) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(
              'Please reach out to us at $email and we will get back to you as soon as possible.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showLegalPlaceholder(BuildContext context, String title) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: const Text(
              'Legal documents will be available here soon. '
              'For now, please contact support@veltrixsports.com for any legal inquiries.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
