import 'package:flutter/material.dart';
import 'main_screen.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  // ড্রপডাউনের জন্য সিলেক্টেড ভ্যালু
  String? selectedZone;
  String? selectedArea;

  // বাংলাদেশের জোন এবং এরিয়ার লিস্ট
  final List<String> zones = [
    'Dhaka',
    'Chattogram',
    'Sylhet',
    'Rajshahi',
    'Khulna',
    'Barishal',
  ];

  // আপাতত ঢাকার ভেতরের কিছু এরিয়া দিলাম (আপনি পরে ডাটাবেস থেকে ডাইনামিক করতে পারবেন)
  final List<String> areas = [
    'Banasree',
    'Gulshan',
    'Dhanmondi',
    'Mirpur',
    'Uttara',
    'Gazipur',
    'Savar',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // ম্যাপের ইলাস্ট্রেশন (আপাতত একটি স্যাম্পল ছবি)
            Image.network(
              'https://cdn-icons-png.flaticon.com/512/854/854878.png',
              height: 150,
            ),
            const SizedBox(height: 40),
            const Text(
              'Select Your Location',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Switch on your location to stay in tune with what's happening in your area",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 60),

            // Your Zone Dropdown
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Zone',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ),
            DropdownButtonFormField<String>(
              value: selectedZone,
              hint: const Text('Types of your zone'),
              icon: const Icon(Icons.keyboard_arrow_down),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF53B175), width: 2),
                ),
              ),
              items: zones.map((String zone) {
                return DropdownMenuItem<String>(value: zone, child: Text(zone));
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedZone = newValue;
                });
              },
            ),
            const SizedBox(height: 30),

            // Your Area Dropdown
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Area',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ),
            DropdownButtonFormField<String>(
              value: selectedArea,
              hint: const Text('Types of your area'),
              icon: const Icon(Icons.keyboard_arrow_down),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF53B175), width: 2),
                ),
              ),
              items: areas.map((String area) {
                return DropdownMenuItem<String>(value: area, child: Text(area));
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedArea = newValue;
                });
              },
            ),
            const SizedBox(height: 50),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF53B175),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  // এখানে ক্লিক করলে পরের স্ক্রিনে যাবে
                  if (selectedZone != null && selectedArea != null) {
                    // আপাতত লোকেশন সিলেক্ট হলে একটি সাকসেস মেসেজ দেখাচ্ছি
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                      (route) => false, // পেছনের সব স্ক্রিন রিমুভ করে দিবে
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select both Zone and Area'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
