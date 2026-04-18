import 'dart:ui'; // Glassmorphism এর জন্য ImageFilter
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:geolocator/geolocator.dart'; // লোকেশন ট্র্যাকিং
import 'package:geocoding/geocoding.dart'; // কো-অর্ডিনেট থেকে ঠিকানায় রূপান্তর
import 'product_detail_screen.dart';
import 'see_all_products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentLocation = "Fetching location...";
  int _selectedFilterIndex = 0; // স্টিকি ফিল্টারের জন্য
  final List<String> _filters = ['All', 'Organic', 'Fruits', 'Veggies', 'Meat'];

  @override
  void initState() {
    super.initState();
    _fetchLiveLocation(); // অ্যাপ ওপেন হলেই লোকেশন খুঁজবে
  }

  // 📍 লাইভ জিপিএস লোকেশন বের করার ফাংশন
  Future<void> _fetchLiveLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _currentLocation = "Location disabled");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _currentLocation = "Permission denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _currentLocation = "Permission denied forever");
      return;
    }

    // লোকেশন ডাটা নেওয়া
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      if (mounted) {
        setState(() {
          _currentLocation = "${place.locality}, ${place.country}"; // যেমন: "Dhaka, Bangladesh"
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7), // হালকা অফ-হোয়াইট ব্যাকগ্রাউন্ড (Premium Look)
      body: CustomScrollView(
        slivers: [
          // 🪟 ১. Glassmorphism AppBar (স্ক্রল করলে নিচে ঝাপসা দেখাবে)
          SliverAppBar(
            pinned: true,
            expandedHeight: 70.0,
            backgroundColor: Colors.white.withOpacity(0.5), // স্বচ্ছতা
            elevation: 0,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // ব্লার ইফেক্ট
                child: Container(color: Colors.transparent),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.eco, color: Color(0xFF53B175), size: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, color: Colors.black54, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      _currentLocation, // 🟢 লাইভ লোকেশন
                      style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            centerTitle: true,
          ),

          // ২. Search Bar & Banner
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildSearchBar(),
                const SizedBox(height: 25),
                _buildCarouselBanner(),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // 💊 ৩. Sticky Filter Chips (স্ক্রল করলে উপরে আটকে থাকবে)
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyFilterDelegate(
              child: Container(
                color: const Color(0xFFF7F9F7), // ব্যাকগ্রাউন্ডের সাথে ম্যাচ করা
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: _buildFilterChips(),
              ),
            ),
          ),

          // ৪. Product Sections
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildSectionHeader(context, 'Exclusive Offer', 'exclusive_offers'),
                _buildProductList('exclusive_offers'),
                const SizedBox(height: 30),

                _buildSectionHeader(context, 'Best Selling', 'best_selling'),
                _buildProductList('best_selling'),
                const SizedBox(height: 40), // বটম প্যাডিং
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Search Bar ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: const TextField(
          decoration: InputDecoration(
            icon: Icon(Icons.search, color: Colors.grey),
            hintText: 'Search fresh groceries...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // --- Sliding Banner ---
  Widget _buildCarouselBanner() {
    final List<String> bannerImages = [
      'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=1000&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?q=80&w=1000&auto=format&fit=crop',
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 140,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.85,
        autoPlayCurve: Curves.fastOutSlowIn,
      ),
      items: bannerImages.map((image) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), // আরও রাউন্ড করা হলো
            image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
            boxShadow: [
              BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: [Colors.black.withOpacity(0.7), Colors.transparent], begin: Alignment.bottomLeft, end: Alignment.topRight),
            ),
            padding: const EdgeInsets.all(20),
            alignment: Alignment.bottomLeft,
            child: const Text(
              'Fresh Vegetables\nUp To 40% OFF',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- Sticky Filters ---
  Widget _buildFilterChips() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      itemCount: _filters.length,
      itemBuilder: (context, index) {
        bool isSelected = _selectedFilterIndex == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedFilterIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF53B175) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? const Color(0xFF53B175) : Colors.grey.shade300),
              boxShadow: isSelected ? [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
            ),
            child: Center(
              child: Text(
                _filters[index],
                style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Section Header ---
  Widget _buildSectionHeader(BuildContext context, String title, String collectionName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SeeAllProductsScreen(collectionName: collectionName, title: title))),
            child: const Text('See all', style: TextStyle(color: Color(0xFF53B175), fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Product List (Firebase) ---
  Widget _buildProductList(String collectionName) {
    return SizedBox(
      height: 260, // কার্ডের উচ্চতা একটু বাড়ানো হয়েছে
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return _buildShimmerLoading();
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No products found."));

          final products = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              var data = products[index].data() as Map<String, dynamic>;
              data['id'] = products[index].id;
              return _buildFloatingProductCard(context, data);
            },
          );
        },
      ),
    );
  }

  // ☁️ --- Floating Product Card (Borderless) ---
  Widget _buildFloatingProductCard(BuildContext context, Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product))),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 15, bottom: 10, top: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), spreadRadius: 2, blurRadius: 15, offset: const Offset(0, 8)), // খুব সফট শ্যাডো
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(child: Hero(tag: product['id'], child: Image.network(product['imageUrl'] ?? '', height: 80, fit: BoxFit.contain))),
                const Spacer(),
                Text(product['name'] ?? 'Unknown', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text("${product['unit'] ?? ''}", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${product['price'] ?? 0.0}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(color: const Color(0xFF53B175), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ],
            ),
            // ❤️ ফেভারিট আইকন (কার্ডের একদম উপরে ডানদিকে)
            Positioned(
              top: 0,
              right: 0,
              child: Icon(Icons.favorite_border, color: Colors.grey.shade400, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.white,
        child: Container(
          width: 160,
          margin: const EdgeInsets.only(right: 15, bottom: 10, top: 5),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}

// 💊 স্টিকি হেডারের জন্য কাস্টম ডেলিগেট
class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyFilterDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;
  @override
  double get maxExtent => 60.0;
  @override
  double get minExtent => 60.0;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}