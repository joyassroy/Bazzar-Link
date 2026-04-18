import 'package:flutter/material.dart';
import 'select_location_screen.dart';
class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  // ওটিপি ধরার জন্য কন্ট্রোলার
  final TextEditingController _otpController = TextEditingController();
  
  // ম্যানুয়াল চেকিংয়ের জন্য ফিক্সড কোড
  final String fixedOTP = "1234";

  void _verifyOTP() {
    if (_otpController.text == fixedOTP) {
      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelectLocationScreen()),
    );
      // পরবর্তীতে এখানে আমরা Location স্ক্রিনে যাওয়ার কোড যোগ করব
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ভুল কোড! দয়া করে 1234 ব্যবহার করুন।'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context), // ব্যাক বাটনে ক্লিক করলে আগের পেজে যাবে
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Enter your 4-digit code',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Code',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            // ওটিপি ইনপুট ফিল্ড (ডিজাইন অনুযায়ী)
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 4, // সর্বোচ্চ ৪ ডিজিট
              style: const TextStyle(fontSize: 24, letterSpacing: 10), // ডিজিটগুলোর মাঝে ফাঁকা জায়গা
              decoration: const InputDecoration(
                hintText: '- - - -',
                counterText: "", // নিচে 0/4 লেখাটি হাইড করার জন্য
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF53B175), width: 2),
                ),
              ),
            ),
            const Spacer(), // এটি নিচের বাটনগুলোকে একদম নিচে ঠেলে দেবে
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Resend Code লজিক
                  },
                  child: const Text(
                    'Resend Code',
                    style: TextStyle(
                      color: Color(0xFF53B175),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                FloatingActionButton(
                  backgroundColor: const Color(0xFF53B175),
                  elevation: 0,
                  shape: const CircleBorder(),
                  onPressed: _verifyOTP,
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 40), // কীবোর্ডের জন্য নিচের দিকে একটু জায়গা রাখা
          ],
        ),
      ),
    );
  }
}