import 'package:flutter/material.dart';
import 'onboarding_screen.dart'; // 🟢 তোমার অনবোর্ডিং বা SignIn স্ক্রিন ইম্পোর্ট করো

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // ৩ সেকেন্ড ওয়েট করবে
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // 🟢 AuthWrapper-এর বদলে Onboarding পেজে পাঠানো হচ্ছে
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(), // তোমার পেজের আসল নাম বসাবে
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF53B175), // BazzarLink এর থিম কালার
      body: Center(
        child: Text(
          'BazzarLink',
          style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}