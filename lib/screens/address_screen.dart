import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  // 🟢 নতুন অ্যাড্রেস অ্যাড বা এডিট করার বটম শিট
  void _showAddressBottomSheet(BuildContext context, {DocumentSnapshot? existingAddress}) {
    final TextEditingController addressController = TextEditingController(
      text: existingAddress != null ? existingAddress['details'] : '',
    );
    String selectedTitle = existingAddress != null ? existingAddress['title'] : 'Home';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // কীবোর্ড উঠলে উপরে ওঠার জন্য
                left: 20, right: 20, top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(existingAddress == null ? 'Add New Address' : 'Edit Address', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // Title Selection (Home / Office)
                  const Text('Address Label', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildLabelChip('Home', selectedTitle, Icons.home_outlined, (val) => setModalState(() => selectedTitle = val)),
                      const SizedBox(width: 10),
                      _buildLabelChip('Office', selectedTitle, Icons.business_outlined, (val) => setModalState(() => selectedTitle = val)),
                      const SizedBox(width: 10),
                      _buildLabelChip('Other', selectedTitle, Icons.location_on_outlined, (val) => setModalState(() => selectedTitle = val)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Address Input Field
                  const Text('Full Address', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                    child: TextField(
                      controller: addressController,
                      maxLines: 3,
                      decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(15), hintText: 'Enter your full delivery address...'),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF53B175), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: () => _saveAddressToDB(selectedTitle, addressController.text.trim(), existingAddress?.id),
                      child: const Text('Save Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLabelChip(String label, String selectedTitle, IconData icon, Function(String) onSelect) {
    bool isSelected = label == selectedTitle;
    return GestureDetector(
      onTap: () => onSelect(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF53B175) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF53B175) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.black54),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // 🟢 ডাটাবেসে সেভ করার লজিক
  Future<void> _saveAddressToDB(String title, String details, String? docId) async {
    if (details.isEmpty) return; // খালি রাখা যাবে না

    Navigator.pop(context); // বটম শিট বন্ধ করা
    if (user == null) return;

    final addressesRef = FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('addresses');

    // চেক করা যে ইউজারের আগে থেকে কোনো অ্যাড্রেস আছে কি না
    final snapshot = await addressesRef.limit(1).get();
    bool isFirstAddress = snapshot.docs.isEmpty;

    if (docId == null) {
      // নতুন অ্যাড্রেস যোগ করা (যদি প্রথম হয়, তবে অটোমেটিক ডিফল্ট হয়ে যাবে)
      await addressesRef.add({
        'title': title,
        'details': details,
        'isDefault': isFirstAddress,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // পুরনো অ্যাড্রেস আপডেট করা
      await addressesRef.doc(docId).update({
        'title': title,
        'details': details,
      });
    }
  }

  // 🟢 ডিফল্ট অ্যাড্রেস সেট করার লজিক
  Future<void> _setDefaultAddress(String targetDocId) async {
    if (user == null) return;

    final addressesRef = FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('addresses');

    // Batch write ব্যবহার করছি, যাতে একসাথে সব অ্যাড্রেসের স্ট্যাটাস চেঞ্জ হয়
    WriteBatch batch = FirebaseFirestore.instance.batch();

    QuerySnapshot allAddresses = await addressesRef.get();

    for (var doc in allAddresses.docs) {
      if (doc.id == targetDocId) {
        batch.update(doc.reference, {'isDefault': true});
      } else {
        batch.update(doc.reference, {'isDefault': false});
      }
    }
    await batch.commit();
  }

  // 🟢 অ্যাড্রেস ডিলিট করার লজিক
  Future<void> _deleteAddress(String docId, bool isDefault) async {
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('addresses').doc(docId).delete();
    // যদি ডিফল্ট অ্যাড্রেস ডিলিট হয়, তাহলে অন্য কোনোটাকে ডিফল্ট করার লজিক এখানে অ্যাড করা যেতে পারে
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
        title: const Text('Delivery Address', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text('Please login to view addresses.'))
          : Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .collection('addresses')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF53B175)));
                }

                // 🌟 ডাটাবেস খালি থাকলে
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final addresses = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    var data = addresses[index];
                    return _buildAddressCard(data);
                  },
                );
              },
            ),
          ),

          // 🟢 Add New Address Button (Sticky Bottom)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF53B175), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add New Address', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () => _showAddressBottomSheet(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(DocumentSnapshot doc) {
    var addressData = doc.data() as Map<String, dynamic>;
    bool isDefault = addressData['isDefault'] ?? false;
    String title = addressData['title'] ?? 'Other';

    return GestureDetector(
      onTap: () {
        if (!isDefault) _setDefaultAddress(doc.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDefault ? const Color(0xFF53B175) : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF53B175).withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(
                title == 'Home' ? Icons.home_outlined : (title == 'Office' ? Icons.business_outlined : Icons.location_on_outlined),
                color: const Color(0xFF53B175), size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      if (isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFF53B175), borderRadius: BorderRadius.circular(8)),
                          child: const Text('Default', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(addressData['details'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4)),
                ],
              ),
            ),

            // Edit & Delete Options Menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (value) {
                if (value == 'edit') {
                  _showAddressBottomSheet(context, existingAddress: doc);
                } else if (value == 'delete') {
                  _deleteAddress(doc.id, isDefault);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18, color: Colors.blue), SizedBox(width: 10), Text('Edit')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 10), Text('Delete', style: TextStyle(color: Colors.red))])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          const Text('No Address Found', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 10),
          const Text('Please add your delivery address\nfor a smooth checkout.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}