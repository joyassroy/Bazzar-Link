import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Help & Support', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // কন্টাক্ট সেকশন
            const Text('Contact Us', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildContactCard(Icons.support_agent, 'Customer Service', 'Call us 24/7', '16222', context),
            const SizedBox(height: 10),
            _buildContactCard(Icons.email_outlined, 'Email Support', 'Write to us', 'support@bazzarlink.com', context),
            const SizedBox(height: 30),

            // FAQ সেকশন
            const Text('FAQs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildFAQTile('How do I track my order?', 'You can track your order by going to the "Orders" section in your Profile and clicking on "Details".'),
            _buildFAQTile('What is the return policy?', 'We offer a 7-day hassle-free return policy for non-perishable items. Fresh produce must be returned within 24 hours.'),
            _buildFAQTile('Can I cancel my order?', 'Yes, you can cancel your order within 10 minutes of placing it from the Orders page.'),
            _buildFAQTile('How does refund work?', 'Refunds will be processed to your original payment method within 3-5 business days.'),
          ],
        ),
      ),
    );
  }

  // কন্টাক্ট কার্ডের ডিজাইন
  Widget _buildContactCard(IconData icon, String title, String subtitle, String action, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF53B175).withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF53B175), size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Text(action, style: const TextStyle(color: Color(0xFF53B175), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // FAQ এর জন্য Expansion Tile
  Widget _buildFAQTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ExpansionTile(
        iconColor: const Color(0xFF53B175),
        collapsedIconColor: Colors.grey,
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
            child: Text(answer, style: const TextStyle(color: Colors.grey, height: 1.5)),
          ),
        ],
      ),
    );
  }
}