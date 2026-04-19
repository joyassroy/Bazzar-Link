import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1; // ডিফল্ট পরিমাণ ১

  // 🛒 কার্টে অ্যাড করার ফাংশন
  Future<void> _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(widget.product['id']);

    // চেক করছি আগে থেকেই কার্টে আছে কি না
    final doc = await cartRef.get();

    if (doc.exists) {
      // থাকলে পরিমাণ বাড়িয়ে দিচ্ছি
      await cartRef.update({
        'quantity': FieldValue.increment(_quantity),
      });
    } else {
      // না থাকলে নতুন করে সেভ করছি
      await cartRef.set({
        ...widget.product,
        'quantity': _quantity,
        'addedAt': Timestamp.now(),
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to Basket!'), backgroundColor: Color(0xFF53B175)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ১. প্রোডাক্ট ইমেজ
            Center(
              child: Hero(
                tag: widget.product['id'],
                child: Image.network(
                  widget.product['imageUrl'],
                  height: 250,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // প্রোডাক্টের নাম
                      Expanded(
                        child: Text(
                          widget.product['name'] ?? 'Unknown',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // 💖 testingggg
                      if (user != null)
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('favorites')
                              .doc(widget.product['id'])
                              .snapshots(),
                          builder: (context, snapshot) {
                            // চেক করছি ডেটাবেসে এই আইটেমটি ফেভারিটে আছে কি না
                            bool isFav = snapshot.hasData && snapshot.data!.exists;

                            return IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : Colors.grey,
                                size: 28,
                              ),
                              onPressed: () async {
                                final favRef = FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .collection('favorites')
                                    .doc(widget.product['id']);

                                if (isFav) {
                                  await favRef.delete(); // ফেভারিট থেকে রিমুভ
                                } else {
                                  await favRef.set(widget.product); // ফেভারিটে অ্যাড
                                }
                              },
                            );
                          },
                        ),
                    ],
                  ),
                  Text("${widget.product['unit'] ?? ''}, Price", style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 20),

                  // ২. কোয়ান্টিটি ও প্রাইজ
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() { if(_quantity > 1) _quantity--; }),
                        icon: const Icon(Icons.remove, color: Colors.grey),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(15)),
                        child: Text("$_quantity", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _quantity++),
                        icon: const Icon(Icons.add, color: Color(0xFF53B175)),
                      ),
                      const Spacer(),
                      Text(
                          "\$${((widget.product['price'] ?? 0) * _quantity).toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                  const Divider(height: 40),

                  // ৩. প্রোডাক্ট ডিটেইল (ডাইনামিক ডেসক্রিপশন)
                  ExpansionTile(
                    title: const Text("Product Detail", style: TextStyle(fontWeight: FontWeight.bold)),
                    initiallyExpanded: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.product['description'] ?? "Premium quality product from BazzarLink. Fresh and organic.",
                            style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF53B175),
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: _addToCart,
          child: const Text("Add To Basket", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}