import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyDetailsScreen extends StatefulWidget {
  const MyDetailsScreen({super.key});

  @override
  State<MyDetailsScreen> createState() => _MyDetailsScreenState();
}

class _MyDetailsScreenState extends State<MyDetailsScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 🟢 ফায়ারবেস থেকে ইউজারের বর্তমান ডেটা টেনে আনা
  Future<void> _loadUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
        if (userDoc.exists) {
          var data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _nameController.text = data['username'] ?? user!.displayName ?? '';
            _phoneController.text = data['phone'] ?? '';
            _addressController.text = data['address'] ?? '';
          });
        }
      } catch (e) {
        debugPrint("Error loading user data: $e");
      }
    }
  }

  // 🟢 আপডেট করা ডেটা ফায়ারবেসে সেভ করা
  Future<void> _updateUserData() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name cannot be empty!'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'username': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // merge: true মানে হলো আগের ডেটা ডিলিট না করে শুধু নতুনগুলো আপডেট করবে

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully! 🎉'), backgroundColor: Color(0xFF53B175)),
        );
        Navigator.pop(context); // আপডেট শেষ হলে আগের পেজে ফেরত যাবে
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // প্রোফাইল ছবি এবং ইমেইল (ইমেইল এডিট করা যাবে না সিকিউরিটির জন্য)
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF53B175).withOpacity(0.1),
                        backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                        child: user?.photoURL == null ? const Icon(Icons.person, size: 50, color: Color(0xFF53B175)) : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Color(0xFF53B175), shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(user?.email ?? 'No email', style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // ইনপুট ফিল্ডস
            _buildInputField(label: 'Full Name', controller: _nameController, icon: Icons.person_outline),
            const SizedBox(height: 20),
            _buildInputField(label: 'Phone Number', controller: _phoneController, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            _buildInputField(label: 'Delivery Address', controller: _addressController, icon: Icons.location_on_outlined, maxLines: 3),

            const SizedBox(height: 40),

            // 🟢 আপডেট বাটন
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF53B175),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
                onPressed: _isLoading ? null : _updateUserData,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Details', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 প্রিমিয়াম লুকের ইনপুট ফিল্ড উইজেট
  Widget _buildInputField({required String label, required TextEditingController controller, required IconData icon, TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100, // হালকা ছাই রঙ ব্যাকগ্রাউন্ড
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: maxLines == 1 ? Icon(icon, color: const Color(0xFF53B175)) : Padding(
                padding: const EdgeInsets.only(bottom: 45.0), // অ্যাড্রেসের আইকনটা উপরে রাখার জন্য
                child: Icon(icon, color: const Color(0xFF53B175)),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}