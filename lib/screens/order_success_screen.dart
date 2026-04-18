import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const NetworkImage('https://img.freepik.com/free-vector/colorful-confetti-background_23-2148472251.jpg'), // হালকা কনফেটি ব্যাকগ্রাউন্ড
            colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.05), BlendMode.dstATop),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // ১. সবুজ টিক আইকন
            Stack(
              alignment: Alignment.center,
              children: [
                Container(width: 180, height: 180, decoration: BoxDecoration(color: const Color(0xFF53B175).withOpacity(0.1), shape: BoxShape.circle)),
                const Icon(Icons.check_circle, color: Color(0xFF53B175), size: 120),
              ],
            ),
            const SizedBox(height: 40),
            // ২. টাইটেল
            const Text("Your Order has been\naccepted", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 20),
            // ৩. বর্ণনা
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text("Your items have been placed and are on their way to being processed.", textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 16)),
            ),
            const Spacer(),
            // ৪. বাটনসমূহ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF53B175), minimumSize: const Size(double.infinity, 65), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    onPressed: () { /* Track Order Page */ },
                    child: const Text("Track Order", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
                    child: const Text("Back to home", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}