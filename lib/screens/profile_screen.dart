import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

// 🟢 সবগুলো সাব-পেজ ইম্পোর্ট করা হলো
import 'my_details_screen.dart';
import 'orders_screen.dart';
import 'address_screen.dart';
import 'payment_methods_screen.dart';
import 'help_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final User? user = FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 🚀 রিয়েল-টাইম Header (StreamBuilder দিয়ে) ---
            StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
                builder: (context, snapshot) {
                  String displayName = user?.displayName ?? 'Valued Customer';
                  String email = user?.email ?? 'No email linked';
                  String? photoUrl = user?.photoURL;

                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    displayName = data['username'] ?? displayName;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFF53B175).withOpacity(0.2),
                          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                          child: photoUrl == null ? const Icon(Icons.person, size: 40, color: Color(0xFF53B175)) : null,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                        displayName,
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyDetailsScreen()));
                                      },
                                      child: const Icon(Icons.edit, color: Colors.green, size: 16)
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(email, style: const TextStyle(color: Colors.grey, fontSize: 14), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
            ),
            const Divider(thickness: 1, color: Colors.black12),

            // --- 🚀 ডাইনামিক মেনু অপশনগুলো ---
            _buildProfileOption(Icons.shopping_bag_outlined, 'Orders', context),
            _buildProfileOption(Icons.person_outline, 'My Details', context),
            _buildProfileOption(Icons.location_on_outlined, 'Delivery Address', context),
            _buildProfileOption(Icons.payment_outlined, 'Payment Methods', context),
            _buildProfileOption(Icons.local_offer_outlined, 'Promo Code', context),
            _buildProfileOption(Icons.notifications_none, 'Notifications', context),
            _buildProfileOption(Icons.help_outline, 'Help', context),
            _buildProfileOption(Icons.info_outline, 'About', context),

            const SizedBox(height: 30),

            // --- Log Out Button (আগের সিকিউর লজিক) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF2F3F2), foregroundColor: const Color(0xFF53B175), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  icon: const Icon(Icons.logout),
                  label: const Text('Log Out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  onPressed: () => _showLogoutDialog(context),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- 🚀 Reusable Option (Master Navigation) ---
  Widget _buildProfileOption(IconData icon, String title, BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black87),
          title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black87),
          onTap: () {
            // 🎯 সেন্ট্রাল নেভিগেশন লজিক
            switch (title) {
              case 'My Details':
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyDetailsScreen()));
                break;
              case 'Orders':
                Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersScreen()));
                break;
              case 'Delivery Address':
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressScreen()));
                break;
              case 'Payment Methods':
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()));
                break;
              case 'Help':
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpScreen()));
                break;
              case 'About':
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
                break;
              default:
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title page coming soon!')));
            }
          },
        ),
        const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Divider(thickness: 1, color: Colors.black12, height: 1)
        ),
      ],
    );
  }

  // --- Log Out Dialog ---
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out from BazzarLink?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF53B175)),
            onPressed: () async {
              Navigator.pop(dialogContext); // প্রথমে ডায়ালগ বন্ধ করবে
              await _authService.signOut(); // এরপর ফায়ারবেস থেকে লগআউট করবে

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}