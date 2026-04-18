import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please log in to see your favorites.")));
    }

    final favCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites');

    final cartCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Favourite', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: favCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF53B175)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Your favorite list is empty!", style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          final favItems = snapshot.data!.docs;

          return Column(
            children: [
              const Divider(color: Colors.black12, thickness: 1),

              // --- ১. ফেভারিট আইটেম লিস্ট ---
              Expanded(
                child: ListView.separated(
                  itemCount: favItems.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.black12, indent: 20, endIndent: 20),
                  itemBuilder: (context, index) {
                    var item = favItems[index].data() as Map<String, dynamic>;
                    String docId = favItems[index].id;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      leading: Image.network(
                        item['imageUrl'] ?? 'https://via.placeholder.com/150',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                      title: Text(item['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text("${item['unit'] ?? ''}, Price", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "\$${(item['price'] ?? 0).toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(width: 10),
                          // 🔴 ডিলিট বা ক্রস আইকন
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                            onPressed: () async {
                              await favCollection.doc(docId).delete();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Removed from favorites"), duration: Duration(seconds: 1)),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // --- ২. Add All To Cart বাটন ---
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF53B175),
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    // 🚀 আর্কিটেক্ট লজিক: সব আইটেম কার্টে পুশ করা
                    _addAllToCart(context, favItems, cartCollection);
                  },
                  child: const Text("Add All To Cart", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 🚀 মাল্টিপল আইটেম কার্টে সেভ করার লজিক
  Future<void> _addAllToCart(BuildContext context, List<QueryDocumentSnapshot> favItems, CollectionReference cartCollection) async {
    try {
      // ইউজারের সুবিধার জন্য লোডিং মেসেজ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Adding items to cart..."), backgroundColor: Colors.blue),
      );

      for (var doc in favItems) {
        var itemData = doc.data() as Map<String, dynamic>;
        String productId = doc.id;

        // চেক করছি আইটেমটি আগে থেকেই কার্টে আছে কি না
        var cartDoc = await cartCollection.doc(productId).get();

        if (cartDoc.exists) {
          // থাকলে পরিমাণ (Quantity) ১ বাড়িয়ে দেব
          await cartCollection.doc(productId).update({
            'quantity': FieldValue.increment(1),
          });
        } else {
          // না থাকলে নতুন করে কার্টে এড করব
          await cartCollection.doc(productId).set({
            ...itemData,
            'quantity': 1, // ডিফল্ট পরিমাণ ১
            'addedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // সাকসেস মেসেজ
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar(); // আগের লোডিং মেসেজ সরাচ্ছি
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All favorites added to cart! 🛒"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}