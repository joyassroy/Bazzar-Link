import 'package:flutter/material.dart';
import 'home_screen.dart'; // হোম স্ক্রিন
import 'explore_screen.dart'; // এক্সপ্লোর স্ক্রিন
import 'cart_screen.dart'; // কার্ট স্ক্রিন
import 'favourite_screen.dart';
import 'profile_screen.dart'; // প্রোফাইল স্ক্রিন

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // নেভিগেশন বারের ট্যাবগুলো অনুযায়ী স্ক্রিন লিস্ট
  final List<Widget> _screens = [
    const HomeScreen(),      // Index 0: Shop
    const ExploreScreen(),   // Index 1: Explore
    const CartScreen(),      // Index 2: Cart
    const FavouriteScreen(),
    ProfileScreen(),         // Index 4: Account
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF53B175), // BazzarLink-এর থিম কালার
        unselectedItemColor: Colors.black54, // আনসিলেক্টেড আইটেম একটু হালকা রাখা ভালো
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favourite'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }
}