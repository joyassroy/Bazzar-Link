import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detail_screen.dart'; // এই ফাইলটি অবশ্যই ইম্পোর্ট করবে

class CategoryItemsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryItemsScreen({
    super.key,
    required this.categoryName
  });

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
        title: Text(
            categoryName,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // আমরা এখন সরাসরি categoryName দিয়ে ফিল্টার করছি যা মেগা ডেটা পুশ করার সময় সেট করেছি
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('categoryName', isEqualTo: categoryName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF53B175)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // যদি নাম দিয়ে না পাওয়া যায়, তবে ব্যাকআপ হিসেবে আইডি দিয়ে ট্রাই করা (আগের লজিক)
            return _buildBackupStream();
          }

          return _buildProductGrid(snapshot.data!.docs);
        },
      ),
    );
  }

  // ব্যাকআপ ফিল্টার লজিক
  Widget _buildBackupStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('categoryId', isEqualTo: _getCategoryIdFromName(categoryName))
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No products found. Please re-upload demo data."));
        }
        return _buildProductGrid(snapshot.data!.docs);
      },
    );
  }

  String _getCategoryIdFromName(String name) {
    if (name.contains("Fruits")) return "c1";
    if (name.contains("Oil")) return "c2";
    if (name.contains("Meat")) return "c3";
    if (name.contains("Bakery")) return "c4";
    if (name.contains("Dairy")) return "c5";
    if (name.contains("Beverages")) return "c6";
    return "";
  }

  Widget _buildProductGrid(List<DocumentSnapshot> docs) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        var product = docs[index].data() as Map<String, dynamic>;

        // 🚀 কার্ডে ক্লিক করলে Detail Screen এ যাওয়ার লজিক
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: _buildProductCard(product),
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ইমেজ পার্ট (Hero Animation যোগ করতে পারো স্মুথনেসের জন্য)
          Expanded(
            child: Center(
              child: Hero(
                tag: product['id'],
                child: Image.network(product['imageUrl'], fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
              product['name'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis
          ),
          Text(
              "${product['unit']}, Price",
              style: const TextStyle(color: Colors.grey, fontSize: 13)
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  "\$${product['price']}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
              ),
              // প্লাস বাটন (এটিও ডিটেইল পেজে নিয়ে যাবে তুমি যেমনটি চেয়েছো)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xFF53B175),
                    borderRadius: BorderRadius.circular(12)
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ],
          )
        ],
      ),
    );
  }
}