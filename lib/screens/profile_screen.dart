import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'my_details_screen.dart'; // 🟢 My Details ইম্পোর্ট করা হলো

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final User? user = FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();

  // --- 🟢 TEMP FUNCTION: মেগা ডেটা পুশ ---
  Future<void> _pushFinalMegaDemoData(BuildContext context) async {
    // (এই ফাংশনের কোড আগের মতোই আছে, আমি আর এখানে বিশাল লিস্টটা লিখলাম না যাতে তোমার কপি করতে সুবিধা হয়।
    // তোমার আগের কোডের এই ফাংশনের ভেতরের ডেটাগুলোই থাকবে। চাইলে তুমি আগেরটা রেখে শুধু বিল্ড মেথডটা আপডেট করতে পারো,
    // তবে কপি-পেস্টের সুবিধার্থে আমি পুরোটা দিয়ে দিচ্ছি ডামি ডেটাসহ।)
    try {
      final db = FirebaseFirestore.instance;
      List<Map<String, dynamic>> categories = [
        {'id': 'c1', 'name': 'Fresh Fruits & Vegetable', 'imageUrl': 'https://cdn-icons-png.flaticon.com/512/2329/2329865.png'},
        {'id': 'c2', 'name': 'Cooking Oil & Ghee', 'imageUrl': 'https://cdn-icons-png.flaticon.com/512/5346/5346124.png'},
      ];
      List<Map<String, dynamic>> allProducts = [
        {'catId': 'c1', 'name': 'Bananas', 'unit': '7pcs', 'price': 80, 'img': 'https://images.unsplash.com/photo-1571771894821-ad9b58a32947?w=500'},
      ];

      for (var cat in categories) await db.collection('categories').doc(cat['id']).set(cat);
      for (int i = 0; i < allProducts.length; i++) {
        var prod = allProducts[i];
        await db.collection('products').doc("${prod['catId']}_prod_$i").set({
          'id': "${prod['catId']}_prod_$i",
          'categoryId': prod['catId'],
          'name': prod['name'],
          'price': prod['price'],
          'unit': prod['unit'],
          'imageUrl': prod['img'],
        });
      }
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Data Uploaded!'), backgroundColor: Colors.green));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red));
    }
  }

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
                  // ডিফল্ট ডেটা (যদি ডাটাবেসে কিছু না থাকে)
                  String displayName = user?.displayName ?? 'Valued Customer';
                  String email = user?.email ?? 'No email linked';
                  String? photoUrl = user?.photoURL;

                  // যদি ডাটাবেসে নাম থাকে, তবে সেটা দেখাবে
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
                                        displayName, // 🟢 এখন রিয়েল-টাইম নাম দেখাবে
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

            // --- Options ---
            _buildProfileOption(Icons.shopping_bag_outlined, 'Orders', context),
            _buildProfileOption(Icons.person_outline, 'My Details', context),
            _buildProfileOption(Icons.location_on_outlined, 'Delivery Address', context),
            _buildProfileOption(Icons.payment_outlined, 'Payment Methods', context),
            _buildProfileOption(Icons.local_offer_outlined, 'Promo Cord', context),
            _buildProfileOption(Icons.notifications_none, 'Notifications', context),
            _buildProfileOption(Icons.help_outline, 'Help', context),
            _buildProfileOption(Icons.info_outline, 'About', context),

            const SizedBox(height: 30),

            // --- Log Out Button ---
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

  // --- Reusable Option ---
  Widget _buildProfileOption(IconData icon, String title, BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black87),
          title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black87),
          onTap: () {
            if (title == 'My Details') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyDetailsScreen()));
            } else if (title == 'Orders') {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Orders page coming soon!')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title page coming soon!')));
            }
          },
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20.0), child: Divider(thickness: 1, color: Colors.black12, height: 1)),
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
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF53B175)),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _authService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
              }
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}