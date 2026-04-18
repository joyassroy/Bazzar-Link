import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  // ডামি পেমেন্ট মেথড লিস্ট
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'p1',
      'title': 'MasterCard',
      'subtitle': '**** **** **** 4242',
      'icon': 'https://cdn-icons-png.flaticon.com/512/196/196561.png', // MasterCard Logo
      'isDefault': true,
    },
    {
      'id': 'p2',
      'title': 'Visa Card',
      'subtitle': '**** **** **** 5567',
      'icon': 'https://cdn-icons-png.flaticon.com/512/196/196578.png', // Visa Logo
      'isDefault': false,
    },
    {
      'id': 'p3',
      'title': 'bKash',
      'subtitle': '+880 1711-XXXXXX',
      'icon': 'https://freelogopng.com/images/all_img/1656234745bkash-app-logo-png.png', // bKash Logo
      'isDefault': false,
    },
    {
      'id': 'p4',
      'title': 'Cash on Delivery',
      'subtitle': 'Pay when you receive',
      'icon': 'https://cdn-icons-png.flaticon.com/512/2800/2800251.png', // Cash Icon
      'isDefault': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7), // হালকা অফ-হোয়াইট
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Payment Methods', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                return _buildPaymentCard(_paymentMethods[index], index);
              },
            ),
          ),

          // 🟢 Add New Card Button (Sticky Bottom)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF53B175),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.add_card, color: Colors.white),
                label: const Text('Add New Card', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add card feature coming soon!')));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 💳 পেমেন্ট কার্ড ডিজাইন
  Widget _buildPaymentCard(Map<String, dynamic> methodData, int index) {
    bool isSelected = methodData['isDefault'];

    return GestureDetector(
      onTap: () {
        // ডিফল্ট পেমেন্ট চেঞ্জ করার লজিক
        setState(() {
          for (var method in _paymentMethods) {
            method['isDefault'] = false;
          }
          _paymentMethods[index]['isDefault'] = true;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF53B175) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            // পেমেন্ট আইকন (Visa/Master/bKash)
            Container(
              height: 40,
              width: 50,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.network(methodData['icon'], fit: BoxFit.contain),
            ),
            const SizedBox(width: 15),

            // টেক্সট (নাম এবং সাবটাইটেল)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(methodData['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(methodData['subtitle'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),

            // চেকমার্ক আইকন (সিলেক্টেড হলে দেখাবে)
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF53B175), size: 24)
            else
              Icon(Icons.circle_outlined, color: Colors.grey.shade300, size: 24),
          ],
        ),
      ),
    );
  }
}