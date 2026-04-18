import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_items_screen.dart'; // এই ফাইলটি নিচে দিচ্ছি

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  // ক্যাটাগরি কার্ডের জন্য কিছু সুন্দর হালকা কালার
  final List<Color> _cardColors = const [
    Color(0xFFEEF7F1), Color(0xFFFEF6ED), Color(0xFFFDE8E4),
    Color(0xFFF4EBF7), Color(0xFFFFF8E5), Color(0xFFEDF7FC),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Find Products', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search Store",
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Categories Grid
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No Categories Found"));
                  }

                  final docs = snapshot.data!.docs;

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var category = docs[index].data() as Map<String, dynamic>;
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryItemsScreen(
                                // আমরা এখন সরাসরি নাম দিয়ে ফিল্টার করব যেন ভুল না হয়
                                categoryName: category['name'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _cardColors[index % _cardColors.length],
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(category['imageUrl'], height: 80, fit: BoxFit.contain),
                              const SizedBox(height: 15),
                              Text(
                                category['name'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}