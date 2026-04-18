import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// তোমার ফোল্ডার স্ট্রাকচার অনুযায়ী ইম্পোর্ট
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ইউজার লগইন করা থাকলে Main Screen-এ যাবে
        if (snapshot.hasData) {
          return const MainScreen();
        }

        // লগইন করা না থাকলে Login Screen-এ যাবে
        return const LoginScreen();
      },
    );
  }
}