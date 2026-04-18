import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'order_success_screen.dart'; // 🟢 তোমার বানানো সাকসেস পেজটি ইম্পোর্ট করা হলো
import 'order_failed_dialog.dart';
import 'address_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalPrice;
  const CheckoutScreen({super.key, required this.totalPrice});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = "Stripe";
  bool _isLoading = false;

  String? _currentDeliveryAddress;
  bool _isAddressLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDefaultAddress();
  }

  // 📍 ফায়ারবেস থেকে ডিফল্ট অ্যাড্রেস নিয়ে আসার লজিক
  Future<void> _fetchDefaultAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (mounted) {
        setState(() {
          if (snapshot.docs.isNotEmpty) {
            _currentDeliveryAddress = snapshot.docs.first['details'];
          } else {
            _currentDeliveryAddress = null;
          }
          _isAddressLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching address: $e");
      if (mounted) setState(() => _isAddressLoading = false);
    }
  }

  // 💳 ১. Stripe Payment Intent
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
          'Authorization': 'Bearer sk_test_51SfC4vHIEGoE5ijPypGpqyROxvhPKGHFkBXDwJMRHATv4c7zYbhRU95sYbFgnd13WA8V9Q7fUuD2ZtDItdHIPsNZ00Y5jzsYVS',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Stripe API Error: ${response.statusCode}");
      }
    } catch (err) {
      throw Exception("Could not connect to Stripe");
    }
  }

  // 🚀 ২. পেমেন্ট শিট চালু করা
  Future<void> _handlePayment(double totalAmount) async {
    if (_currentDeliveryAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a delivery address first!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final paymentIntentData = await _createPaymentIntent((totalAmount * 100).toInt().toString(), 'USD');

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          style: ThemeMode.light,
          merchantDisplayName: 'BazzarLink',
          googlePay: const PaymentSheetGooglePay(merchantCountryCode: 'US', testEnv: true),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      if (mounted) {
        _confirmOrder(totalAmount, "Stripe (Paid)");
      }

    } on StripeException catch (e) {
      debugPrint("Stripe Exception: ${e.error.localizedMessage}");
      if (mounted) showDialog(context: context, barrierDismissible: false, builder: (context) => const OrderFailedDialog());
    } catch (e) {
      if (mounted) showDialog(context: context, barrierDismissible: false, builder: (context) => const OrderFailedDialog());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 📦 ৩. অর্ডার কনফার্ম করে Firestore এ সেভ করা
  Future<void> _confirmOrder(double amount, String method) async {
    if (_currentDeliveryAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a delivery address!'), backgroundColor: Colors.red));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // 🟢 ডাটাবেসে অর্ডার পুশ করা (যাতে Orders পেজে ট্র্যাক করা যায়)
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'totalAmount': amount,
        'status': 'Processing',
        'paymentMethod': method,
        'deliveryAddress': _currentDeliveryAddress,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // কার্ট ক্লিয়ার করা
      var cartItems = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('cart').get();
      for (var doc in cartItems.docs) {
        await doc.reference.delete();
      }

      // 🚀 🟢 Order Success পেজে পাঠানো এবং আগের সব হিস্ট্রি ডিলিট করা
      if (mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
                (route) => false
        );
      }
    } catch (e) {
      debugPrint("Order Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            const SizedBox(height: 10),

            // 🟢 ডাইনামিক অ্যাড্রেস ফিল্ড
            _isAddressLoading
                ? const Padding(padding: EdgeInsets.all(15), child: CircularProgressIndicator())
                : Container(
              decoration: BoxDecoration(
                color: _currentDeliveryAddress == null ? Colors.red.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _currentDeliveryAddress == null ? Colors.red.shade200 : Colors.grey.shade200),
              ),
              child: ListTile(
                leading: Icon(Icons.location_on, color: _currentDeliveryAddress == null ? Colors.red : const Color(0xFF53B175)),
                title: Text(
                  _currentDeliveryAddress ?? "No address found. Please add one.",
                  style: TextStyle(color: _currentDeliveryAddress == null ? Colors.red : Colors.black87),
                ),
                trailing: const Icon(Icons.edit, size: 20, color: Color(0xFF53B175)),
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressScreen()));
                  _fetchDefaultAddress();
                },
              ),
            ),

            const SizedBox(height: 30),
            const Text("Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  RadioListTile(
                    title: const Text("Credit Card (Stripe)"),
                    secondary: const Icon(Icons.credit_card, color: Colors.blueAccent),
                    value: "Stripe",
                    groupValue: _selectedPaymentMethod,
                    activeColor: const Color(0xFF53B175),
                    onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
                  ),
                  const Divider(height: 1),
                  RadioListTile(
                    title: const Text("Cash on Delivery"),
                    secondary: const Icon(Icons.money, color: Colors.green),
                    value: "COD",
                    groupValue: _selectedPaymentMethod,
                    activeColor: const Color(0xFF53B175),
                    onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSummaryRow("Subtotal", widget.totalPrice),
            _buildSummaryRow("Delivery Charge", deliveryCharge),
            const Divider(height: 30, thickness: 1),
            _buildSummaryRow("Total Amount", finalTotal, isTotal: true),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF53B175),
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isTotal ? Colors.black : Colors.grey.shade700, fontSize: isTotal ? 20 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text("\$${val.toStringAsFixed(2)}", style: TextStyle(color: isTotal ? const Color(0xFF53B175) : Colors.black87, fontSize: isTotal ? 20 : 16, fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold)),
        ],
      ),
    );
  }
}