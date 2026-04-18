import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please log in to see your cart")));
    }

    final cartCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Cart', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF53B175)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Your cart is empty!"));
          }

          final cartItems = snapshot.data!.docs;

          // ✅ ম্যাজিক ফিক্স ১: ListView রেন্ডার হওয়ার আগেই টোটাল প্রাইজ ক্যালকুলেট করে নিচ্ছি
          double totalPrice = 0;
          for (var doc in cartItems) {
            var data = doc.data() as Map<String, dynamic>;
            totalPrice += (data['price'] ?? 0) * (data['quantity'] ?? 0);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: cartItems.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.grey, thickness: 0.5),
                  itemBuilder: (context, index) {
                    var item = cartItems[index].data() as Map<String, dynamic>;
                    String docId = cartItems[index].id;

                    return _buildCartItem(item, docId, cartCollection);
                  },
                ),
              ),

              // ✅ ম্যাজিক ফিক্স ২: context এবং সঠিক totalPrice পাস করা হচ্ছে
              _buildCheckoutButton(context, totalPrice),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, String docId, CollectionReference cartCollection) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Image.network(
            item['imageUrl'],
            width: 70,
            height: 70,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () async {
                        await cartCollection.doc(docId).delete();
                      },
                    ),
                  ],
                ),
                Text("${item['unit']}, Price", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _buildQuantityButton(Icons.remove, Colors.grey, () async {
                      if (item['quantity'] > 1) {
                        await cartCollection.doc(docId).update({
                          'quantity': FieldValue.increment(-1),
                        });
                      }
                    }),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text("${item['quantity']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    _buildQuantityButton(Icons.add, const Color(0xFF53B175), () async {
                      await cartCollection.doc(docId).update({
                        'quantity': FieldValue.increment(1),
                      });
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Text(
            "\$${(item['price'] * item['quantity']).toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, Color iconColor, Future<void> Function() onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  // ✅ এখানে BuildContext অ্যাড করা হয়েছে যাতে Navigator কাজ করে
  Widget _buildCheckoutButton(BuildContext context, double totalPrice) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF53B175),
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckoutScreen(totalPrice: totalPrice),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Go to Checkout", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                  "\$${totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
              ),
            ),
          ],
        ),
      ),
    );
  }
}