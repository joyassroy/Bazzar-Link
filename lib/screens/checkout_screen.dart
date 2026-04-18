import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'order_success_screen.dart';
import 'order_failed_dialog.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalPrice;
  const CheckoutScreen({super.key, required this.totalPrice});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedAddress = "Banasree, Dhaka-1219, House #12, Block #B";
  String _selectedPaymentMethod = "Stripe";
  bool _isLoading = false;

  // 💳 ১. Stripe Payment Intent তৈরি করা
  Future<Map<String, dynamic>> _createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          // 🔑 তোমার Secret Key (নিশ্চিত করো এর আগে-পিছে কোনো স্পেস নেই)
          'Authorization': 'Bearer sk_test_51SfC4vHIEGoE5ijPypGpqyROxvhPKGHFkBXDwJMRHATv4c7zYbhRU95sYbFgnd13WA8V9Q7fUuD2ZtDItdHIPsNZ00Y5jzsYVS',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint("Stripe Error Response: ${response.body}");
        throw Exception("Stripe API Error: ${response.statusCode}");
      }
    } catch (err) {
      debugPrint("Payment Intent Error: $err");
      throw Exception("Could not connect to Stripe");
    }
  }

  // 🚀 ২. পেমেন্ট শিট চালু করা
  Future<void> _handlePayment(double totalAmount) async {
    setState(() => _isLoading = true);

    try {
      // পেমেন্ট ইনটেন্ট কল
      final paymentIntentData = await _createPaymentIntent(
          (totalAmount * 100).toInt().toString(), 'USD');

      // শিট কনফিগার করা
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          style: ThemeMode.light,
          merchantDisplayName: 'BazzarLink',
          googlePay: const PaymentSheetGooglePay(merchantCountryCode: 'US', testEnv: true),
        ),
      );

      // শিট দেখানো
      await Stripe.instance.presentPaymentSheet();

      // পেমেন্ট সফল হলে
      if (mounted) {
        _confirmOrder(totalAmount, "Stripe (Paid)");
      }

    } on StripeException catch (e) {
      debugPrint("Stripe Exception: ${e.error.localizedMessage}");
      if (mounted) {
        // SnackBar er bodole Custom Dialog show korchi
        showDialog(
          context: context,
          barrierDismissible: false, // Baire click korle jeno close na hoy
          builder: (context) => const OrderFailedDialog(),
        );
      }
    } catch (e) {
      debugPrint("General Error: $e");
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const OrderFailedDialog(),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 📦 ৩. অর্ডার কনফার্ম করে Firestore এ সেভ করা
  Future<void> _confirmOrder(double amount, String method) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'totalAmount': amount,
        'status': 'Accepted',
        'paymentMethod': method,
        'deliveryAddress': _selectedAddress,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // কার্ট ক্লিয়ার করা
      var cartItems = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get();

      for (var doc in cartItems.docs) {
        await doc.reference.delete();
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
              (route) => false, // আগের সব পেজ হিস্ট্রি থেকে মুছে ফেলবে
        );
      }
    } catch (e) {
      debugPrint("Order Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double deliveryCharge = 15.0;
    double finalTotal = widget.totalPrice + deliveryCharge;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Checkout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF53B175)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Delivery Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on_outlined, color: Color(0xFF53B175)),
              title: Text(_selectedAddress),
              trailing: const Icon(Icons.edit, size: 18, color: Colors.green),
              onTap: () { /* ঠিকানা পরিবর্তনের লজিক */ },
            ),
            const Divider(),
            const SizedBox(height: 20),
            const Text("Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            RadioListTile(
              title: const Text("Stripe (Credit Card)"),
              value: "Stripe",
              groupValue: _selectedPaymentMethod,
              activeColor: const Color(0xFF53B175),
              onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
            ),
            RadioListTile(
              title: const Text("Cash on Delivery"),
              value: "COD",
              groupValue: _selectedPaymentMethod,
              activeColor: const Color(0xFF53B175),
              onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
            ),
            const Divider(),
            const SizedBox(height: 30),
            _buildSummaryRow("Subtotal", widget.totalPrice),
            _buildSummaryRow("Delivery Charge", deliveryCharge),
            _buildSummaryRow("Total Amount", finalTotal, isTotal: true),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF53B175),
            minimumSize: const Size(double.infinity, 65),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: _isLoading ? null : () {
            if (_selectedPaymentMethod == "Stripe") {
              _handlePayment(finalTotal);
            } else {
              _confirmOrder(finalTotal, "Cash on Delivery");
            }
          },
          child: const Text("Place Order", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double val, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 20 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text("\$${val.toStringAsFixed(2)}", style: TextStyle(fontSize: isTotal ? 20 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}