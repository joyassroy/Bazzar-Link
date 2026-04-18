import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart'; // নতুন বাটন এনিমেশন
import 'package:confetti/confetti.dart'; // সফল সাইনআপ এনিমেশন
import 'main_screen.dart'; // হোম পেজে যাওয়ার জন্য
import 'login_screen.dart'; // লগইনে ফেরত যাওয়ার জন্য

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true; // পাসওয়ার্ড লুকানো/দেখানো
  late ConfettiController _confettiController; // কনফেটি কন্ট্রোলার

  @override
  void initState() {
    super.initState();
    // কনফেটি কন্ট্রোলার ইনিশিয়ালাইজ (সফল সাইনআপের জন্য)
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    // কন্ট্রোলারগুলো রিমুভ (memory leak রোধে)
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  // 🚀 ১. সাইনআপ লজিক (FirebaseAuth এবং Firestore)
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // ফায়ারবেস অথেন্টিকেশনে ইউজার তৈরি
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim());

        if (userCredential.user != null) {
          // Firestore এ ইউজারের এক্সট্রা ডেটা সেভ
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'uid': userCredential.user!.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });

          // 🎉 সাকসেস এনিমেশন (Confetti পপ)
          _confettiController.play();

          // ৩ সেকেন্ড পর হোম স্ক্রিনে নিয়ে যাওয়া
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                      (route) => false);
            }
          });
        }
      } on FirebaseAuthException catch (e) {
        String message = "Registration failed. Try again!";
        if (e.code == 'weak-password') message = "The password is too weak.";
        if (e.code == 'email-already-in-use') message = "The account already exists.";

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ));
        }
      } catch (e) {
        debugPrint("Error: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    // ১. ক্যারট লোগো (image_4.png এর মতো)
                    Center(
                      child: Image.network(
                        'https://cdn-icons-png.flaticon.com/512/590/590807.png', // ক্যারট লোগো
                        height: 70,
                      ),
                    ),
                    const SizedBox(height: 50),

                    // ২. সাইনআপ টাইটেল
                    const Text("Sign Up", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    const SizedBox(height: 10),
                    const Text("Enter your credentials to continue", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 40),

                    // ৩. ইউজারনেম ফিল্ড
                    _buildLabel("Username"),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(hintText: "Enter your username"),
                      validator: (value) => (value == null || value.isEmpty) ? "Username required" : null,
                    ),
                    const SizedBox(height: 25),

                    // ৪. ইমেল ফিল্ড (validation indicator সহ)
                    _buildLabel("Email"),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Enter your email",
                        suffixIcon: _buildEmailStatusIcon(), // স্ট্যাটাস আইকন
                      ),
                      validator: (value) => (value == null || !value.contains('@')) ? "Invalid email" : null,
                      onChanged: (_) => setState(() {}), // আইকন আপডেট
                    ),
                    const SizedBox(height: 25),

                    // ৫. পাসওয়ার্ড ফিল্ড (show/hide toggle সহ)
                    _buildLabel("Password"),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey,),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) => (value == null || value.length < 6) ? "Password min 6 chars" : null,
                    ),
                    const SizedBox(height: 20),

                    // ৬. টার্মস অফ সার্ভিস
                    const Text(
                      "By continuing you agree to our Terms Of Service and Privacy Policy.",
                      style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 40),

                    // 💖 ৭. এনিমেটেড সাইনআপ বাটন (image_4.png এর মতো সবুজ)
                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF53B175)))
                        : AnimatedButton(
                      height: 65,
                      width: double.infinity,
                      text: "Sing Up", // ইউআই-এর মতো বানান রাখা হয়েছে
                      isReverse: true,
                      selectedTextColor: Colors.white,
                      transitionType: TransitionType.LEFT_TO_RIGHT,
                      textStyle: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      backgroundColor: const Color(0xFF53B175),
                      borderColor: const Color(0xFF53B175),
                      borderRadius: 20,
                      onPress: _signUp,
                    ),
                    const SizedBox(height: 20),

                    // ৮. লগইন লিঙ্ক (Login)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? ", style: TextStyle(color: Colors.black)),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                          },
                          child: const Text("Log in", style: TextStyle(color: Color(0xFF53B175), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // 🎉 সাকসেস এনিমেশন উইজেট
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive, // সব দিকে ছড়িয়ে পড়বে
              colors: const [Colors.green, Colors.red, Colors.blue, Colors.yellow],
              shouldLoop: false,
              minimumSize: const Size(10, 10),
              maximumSize: const Size(20, 20),
            ),
          ),
        ],
      ),
    );
  }

  // ইমেল স্ট্যাটাস আইকন উইজেট
  Widget? _buildEmailStatusIcon() {
    String email = _emailController.text.trim();
    if (email.isEmpty) return null;
    if (email.contains('@')) return const Icon(Icons.check, color: Color(0xFF53B175));
    return const Icon(Icons.close, color: Colors.red);
  }

  // ফিল্ড লেবেল উইজেট
  Widget _buildLabel(String label) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
      ],
    );
  }
}