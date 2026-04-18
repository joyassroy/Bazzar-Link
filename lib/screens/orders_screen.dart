import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  Timer? _statusUpdateTimer;

  final List<String> _statusFlow = [
    'Processing',
    'Product Ready',
    'Parcel in your area',
    'Rider is calling',
    'Delivered'
  ];

  @override
  void initState() {
    super.initState();
    _startTrackingSimulation();
  }

  void _startTrackingSimulation() {
    if (user == null) return;

    _statusUpdateTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      try {
        // 🚀 ফিক্স: কোনো ডাবল where() নেই, ফলে কোনো Index Error হবে না!
        var snapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user!.uid)
            .get();

        for (var doc in snapshot.docs) {
          var data = doc.data();

          // 🚀 ফিক্স: লোকাল ফিল্টারিং (যদি ডেলিভার্ড হয়ে যায়, তবে স্কিপ করবে)
          if (data['status'] == 'Delivered') continue;
          if (data['createdAt'] == null) continue;

          DateTime orderTime = (data['createdAt'] as Timestamp).toDate();
          int secondsPassed = DateTime.now().difference(orderTime).inSeconds;

          String currentStatus = data['status'] ?? 'Processing';
          String expectedStatus = _statusFlow[0];

          if (secondsPassed >= 60) {
            expectedStatus = _statusFlow[4];
          } else if (secondsPassed >= 45) {
            expectedStatus = _statusFlow[3];
          } else if (secondsPassed >= 30) {
            expectedStatus = _statusFlow[2];
          } else if (secondsPassed >= 15) {
            expectedStatus = _statusFlow[1];
          }

          if (currentStatus != expectedStatus) {
            await doc.reference.update({'status': expectedStatus});
            debugPrint("✅ Order ${doc.id} updated to: $expectedStatus");
          }
        }
      } catch (e) {
        debugPrint("Tracking error: $e");
      }
    });
  }

  @override
  void dispose() {
    _statusUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Orders', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text("Please login to see orders."))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {

          // 🟢 এরর হ্যান্ডলিং
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", textAlign: TextAlign.center));
          }

          // 🚀 ফিক্স: শুধু তখনই লোডিং দেখাবে যখন একদমই কোনো ডেটা নেই এবং ওয়েটিংয়ে আছে
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF53B175)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(context);
          }

          var orders = snapshot.data!.docs.toList();

          // লোকাল সর্টিং (নতুনগুলো উপরে)
          orders.sort((a, b) {
            var dataA = a.data() as Map<String, dynamic>;
            var dataB = b.data() as Map<String, dynamic>;
            Timestamp? timeA = dataA['createdAt'];
            Timestamp? timeB = dataB['createdAt'];

            if (timeA == null || timeB == null) return 0;
            return timeB.compareTo(timeA);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var orderData = orders[index].data() as Map<String, dynamic>;
              String orderId = orders[index].id;
              return _buildOrderCard(orderData, orderId);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> orderData, String orderId) {
    String status = orderData['status'] ?? 'Processing';
    int statusIndex = _statusFlow.indexOf(status);
    if (statusIndex == -1) statusIndex = 0;

    double progress = (statusIndex + 1) / _statusFlow.length;
    bool isDelivered = status == 'Delivered';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDelivered ? const Color(0xFF53B175).withOpacity(0.3) : Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #${orderId.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('\$${orderData['totalAmount']?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(color: Color(0xFF53B175), fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.payment, size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(orderData['paymentMethod'] ?? 'Unknown', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Expanded(
                child: Text(orderData['deliveryAddress'] ?? 'No address', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ),
            ],
          ),

          const Divider(height: 30, thickness: 1, color: Colors.black12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status,
                style: TextStyle(
                    color: isDelivered ? const Color(0xFF53B175) : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 15
                ),
              ),
              if (!isDelivered)
                const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange)),
              if (isDelivered)
                const Icon(Icons.check_circle, color: Color(0xFF53B175), size: 20)
            ],
          ),
          const SizedBox(height: 15),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(isDelivered ? const Color(0xFF53B175) : Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          const Text('No ongoing orders', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 10),
          const Text('Looks like you haven\'t made any\npurchases yet.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}