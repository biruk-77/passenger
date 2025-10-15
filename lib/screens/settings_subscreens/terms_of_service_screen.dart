import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
              title: '1. Introduction',
              content:
                  'Welcome to our daily transport service. By using our app, you agree to these Terms of Service. These terms govern your access to and use of our platform for booking and managing rides.',
            ),
            const _buildSection(
              title: '2. User Accounts',
              content:
                  'You must create an account to use our services. You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account. You must provide accurate and complete information.',
            ),
            const _buildSection(
              title: '3. Booking and Payments',
              content:
                  'When you request a ride, you agree to pay the estimated fare. All payments are processed through our secure payment gateway. We are not responsible for any errors made by the payment processor. Fares are subject to change based on demand and other factors.',
            ),
            const _buildSection(
              title: '4. User Conduct',
              content:
                  'You agree to use our services for lawful purposes only. You will not cause nuisance, annoyance, inconvenience, or property damage to the driver or any other party. Respect for our drivers and fellow passengers is mandatory.',
            ),
             const _buildSection(
              title: '5. Limitation of Liability',
              content:
                  'Our service is provided "as is". We do not guarantee the quality, suitability, safety, or ability of drivers. We are not liable for any damages arising from your use of the service, including direct, indirect, incidental, or consequential damages.',
            ),
          ],
        ),
      ),
    );
  }
}

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
