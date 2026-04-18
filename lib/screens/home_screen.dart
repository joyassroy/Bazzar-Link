import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'product_detail_screen.dart';
import 'see_all_products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentLocation = "Fetching location...";

  // 🟢 সার্চ এবং ফিল্টারের জন্য নতুন ভেরিয়েবল
  int _selectedFilterIndex = 0;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = ['All', 'Organic', 'Fruits', 'Veggies', 'Meat'];

  @override
  void initState() {
    super.initState();
    _fetchLiveLocation();
  }

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

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      if (mounted) {
        setState(() {
          _currentLocation = "${place.locality}, ${place.country}";
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 চেক করা হচ্ছে ইউজার কিছু সার্চ করছে কি না বা ফিল্টার চেঞ্জ করেছে কি না
    bool isFiltering = _searchQuery.isNotEmpty || _selectedFilterIndex != 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      body: CustomScrollView(
        slivers: [
          // 🪟 ১. Glassmorphism AppBar
          SliverAppBar(
            pinned: true,
            expandedHeight: 70.0,
            backgroundColor: Colors.white.withOpacity(0.5),
            elevation: 0,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                      _currentLocation,
                      style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            centerTitle: true,
          ),

          // ২. Search Bar
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildSearchBar(),
                const SizedBox(height: 20),
                // সার্চ করলে ব্যানার হাইড হয়ে যাবে
                if (!isFiltering) _buildCarouselBanner(),
                if (!isFiltering) const SizedBox(height: 20),
              ],
            ),
          ),

          // 💊 ৩. Sticky Filter Chips
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyFilterDelegate(
              child: Container(
                color: const Color(0xFFF7F9F7),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: _buildFilterChips(),
              ),
            ),
          ),

          // ৪. 🚀 Dynamic Body (হয় রেগুলার হোমপেজ দেখাবে, নয়তো ফিল্টার করা রেজাল্ট)
          if (!isFiltering) ...[
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
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ] else ...[
            // 🟢 ফিল্টার করা প্রোডাক্টের গ্রিড ভিউ
            _buildFilteredResultsGrid(),
          ]
        ],
      ),
    );
  }

  // --- 🚀 Search Bar ---
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
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value; // 🟢 টাইপ করার সাথে সাথে ভ্যালু আপডেট হবে
            });
          },
          decoration: InputDecoration(
            icon: const Icon(Icons.search, color: Colors.grey),
            hintText: 'Search fresh groceries...',
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            // ক্লিয়ার বাটন
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = "");
              },
            )
                : null,
          ),
        ),
      ),
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
          onTap: () {
            setState(() {
              _selectedFilterIndex = index; // 🟢 ফিল্টার বাটন ক্লিক করলে আপডেট হবে
            });
          },
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

  // 🚀 🟢 ফিল্টার করা রেজাল্ট গ্রিড ভিউতে দেখানোর ফাংশন
  Widget _buildFilteredResultsGrid() {
    return StreamBuilder<QuerySnapshot>(
      // তোমার পুশ করা মেগা 'products' কালেকশন থেকে ডেটা টানছে
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator(color: Color(0xFF53B175)))));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverToBoxAdapter(child: Center(child: Text("No products found in database.")));
        }

        // 🟢 লোকাল ফিল্টারিং লজিক
        var filteredProducts = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          String name = (data['name'] ?? '').toLowerCase();
          String catId = data['categoryId'] ?? '';

          // ১. সার্চ টেক্সট ম্যাচ করানো
          if (_searchQuery.isNotEmpty && !name.contains(_searchQuery.toLowerCase())) {
            return false;
          }

          // ২. ফিল্টার চিপস ম্যাচ করানো
          if (_selectedFilterIndex == 1 && !name.contains('organic')) return false; // Organic (নামে অর্গানিক থাকতে হবে)
          if (_selectedFilterIndex == 2 && catId != 'c1') return false; // Fruits (c1)
          if (_selectedFilterIndex == 3 && catId != 'c1') return false; // Veggies (c1)
          if (_selectedFilterIndex == 4 && catId != 'c3') return false; // Meat (c3)

          return true; // যদি সবগুলো পাস করে
        }).toList();

        // যদি সার্চে কিছু না পাওয়া যায়
        if (filteredProducts.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 15),
                    const Text("No items match your search.", style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          );
        }

        // রেজাল্ট গ্রিড আকারে দেখানো
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // ২ কলাম
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.72, // কার্ডের হাইট-উইডথ রেশিও
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                var data = filteredProducts[index].data() as Map<String, dynamic>;
                data['id'] = filteredProducts[index].id;
                return _buildGridProductCard(context, data);
              },
              childCount: filteredProducts.length,
            ),
          ),
        );
      },
    );
  }

  // গ্রিডের জন্য স্পেশাল প্রোডাক্ট কার্ড (মার্জিন ছাড়া)
  Widget _buildGridProductCard(BuildContext context, Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product))),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), spreadRadius: 2, blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(child: Hero(tag: product['id'], child: Image.network(product['imageUrl'] ?? '', height: 75, fit: BoxFit.contain))),
                const Spacer(),
                Text(product['name'] ?? 'Unknown', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: -0.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text("${product['unit'] ?? ''}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${product['price'] ?? 0.0}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    Container(
                      height: 32, width: 32,
                      decoration: BoxDecoration(color: const Color(0xFF53B175), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.add, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(top: 0, right: 0, child: Icon(Icons.favorite_border, color: Colors.grey.shade400, size: 20)),
          ],
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
      options: CarouselOptions(height: 140, autoPlay: true, enlargeCenterPage: true, viewportFraction: 0.85, autoPlayCurve: Curves.fastOutSlowIn),
      items: bannerImages.map((image) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
            boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: [Colors.black.withOpacity(0.7), Colors.transparent], begin: Alignment.bottomLeft, end: Alignment.topRight),
            ),
            padding: const EdgeInsets.all(20),
            alignment: Alignment.bottomLeft,
            child: const Text('Fresh Vegetables\nUp To 40% OFF', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ),
        );
      }).toList(),
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
      height: 260,
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), spreadRadius: 2, blurRadius: 15, offset: const Offset(0, 8))],
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
                      height: 35, width: 35,
                      decoration: BoxDecoration(color: const Color(0xFF53B175), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(top: 0, right: 0, child: Icon(Icons.favorite_border, color: Colors.grey.shade400, size: 22)),
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
        baseColor: Colors.grey.shade200, highlightColor: Colors.white,
        child: Container(width: 160, margin: const EdgeInsets.only(right: 15, bottom: 10, top: 5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
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