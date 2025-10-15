import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'Last Updated: [Date]',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            const _buildSection(
              title: '1. Information We Collect',
              content:
                  'We collect information you provide directly to us, such as when you create an account, request a ride, or contact customer support. This includes your name, phone number, and payment information. We also collect location data to facilitate rides.',
            ),
            const _buildSection(
              title: '2. How We Use Your Information',
              content:
                  'Your information is used to provide, maintain, and improve our services. This includes connecting you with drivers, processing payments, and sending service-related communications. Your location data is shared with your driver to facilitate pickup.',
            ),
            const _buildSection(
              title: '3. Information Sharing',
              content:
                  'We may share your information with our drivers to enable them to provide the service you request. We do not sell your personal information to third parties. We may share information if required by law or to protect the rights and safety of our company and users.',
            ),
             const _buildSection(
              title: '4. Data Security',
              content:
                  'We take reasonable measures to protect your personal information from loss, theft, misuse, and unauthorized access. However, no internet-based service is 100% secure, and we cannot guarantee absolute security.',
            ),
          ],
        ),
      ),
    );
  }
}

// Re-using the helper widget from the other file for consistency
class _buildSection extends StatelessWidget {
  final String title;
  final String content;

  const _buildSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(content, textAlign: TextAlign.justify),
        ],
      ),
    );
  }
}