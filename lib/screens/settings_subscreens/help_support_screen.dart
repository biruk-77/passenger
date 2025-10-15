// lib/screens/settings_subscreens/help_support_screen.dart
import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        // --- ✅ FIX: Removed the `const` keyword from this list ---
        children: [
          _buildSectionTitle('Frequently Asked Questions (FAQ)'),
          _buildFaqItem(
            question: 'How do I book a ride?',
            answer:
                'To book a ride, set your pickup and destination locations on the home screen map. Choose your preferred vehicle type and confirm your request. A nearby driver will be assigned to you shortly.',
          ),
          _buildFaqItem(
            question: 'How is the fare calculated?',
            answer:
                'Fares are calculated based on the distance of the trip and the vehicle type selected. You will see an estimated fare before you confirm your booking. For contract rides, the fare is predetermined in your subscription.',
          ),
          _buildFaqItem(
            question: 'Can I cancel a ride?',
            answer:
                'Yes, you can cancel a ride before a driver starts the trip. Please note that a cancellation fee may apply if you cancel after a driver has already been dispatched and is on their way to you.',
          ),
          const SizedBox(height: 24), // SizedBox itself can be const
          _buildSectionTitle('Contact Us'),
          _buildContactItem(
            icon: Icons.phone,
            title: 'Customer Support Hotline',
            subtitle: '+251-9XX-XXXXXX',
          ),
          _buildContactItem(
            icon: Icons.email,
            title: 'Support Email',
            subtitle: 'support@yourcompany.com',
          ),
          _buildContactItem(
            icon: Icons.location_on,
            title: 'Our Office',
            subtitle: 'Bole Road, Addis Ababa, Ethiopia',
          ),
        ],
      ),
    );
  }
}

// Helper Widgets (These do not need to be changed)
Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
  );
}

Widget _buildFaqItem({required String question, required String answer}) {
  return ExpansionTile(
    title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(answer),
      ),
    ],
  );
}

Widget _buildContactItem({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 4.0),
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    ),
  );
}
