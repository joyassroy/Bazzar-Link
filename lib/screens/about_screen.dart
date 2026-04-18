import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('About Us', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          // অ্যাপের লোগো ও নাম
          const Center(
            child: Column(
              children: [
                Icon(Icons.eco, size: 80, color: Color(0xFF53B175)),
                SizedBox(height: 10),
                Text('BazzarLink', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 5),
                Text('Version 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // অ্যাপের শর্ট ডেসক্রিপশন
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'BazzarLink is your ultimate smart pantry solution. We deliver fresh groceries directly to your doorstep within hours. Shop smart, live healthy!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
            ),
          ),
          const SizedBox(height: 40),

          // পলিসি মেনু
          _buildAboutMenu(Icons.article_outlined, 'Terms of Service', context),
          _buildAboutMenu(Icons.privacy_tip_outlined, 'Privacy Policy', context),
          _buildAboutMenu(Icons.star_outline, 'Rate Us on Play Store', context),

          const Spacer(),
          const Text('© 2026 BazzarLink Ltd.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildAboutMenu(IconData icon, String title, BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 30),
          leading: Icon(icon, color: const Color(0xFF53B175)),
          title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening $title...')));
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Divider(thickness: 1, color: Colors.black12, height: 1),
        ),
      ],
    );
  }
}