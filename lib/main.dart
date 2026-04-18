import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // স্ট্রাইপ ইম্পোর্ট
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔑 তোমার Stripe Publishable Key এখানে বসাও (Stripe Dashboard থেকে পাবে)
  Stripe.publishableKey = "pk_test_51SfC4vHIEGoE5ijPQuY7T3iN4fV2e3kepSSN0qoB7e804Jzlyp6IXyVdGzmAoo0Dt1s4yOOcKZhfgAdHo7v54tyu000UWB6t0D";
  await Stripe.instance.applySettings();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BazzarLinkApp());
}

class BazzarLinkApp extends StatelessWidget {
  const BazzarLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BazzarLink',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF53B175)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}