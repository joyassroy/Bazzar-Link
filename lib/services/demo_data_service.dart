import 'package:cloud_firestore/cloud_firestore.dart';

class DemoDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> uploadMegaData() async {
    print("Uploading 60 products... This might take a few seconds.");

    // ১. ক্যাটাগরি লিস্ট (Working Icon Links)
    List<Map<String, dynamic>> categories = [
      {'id': 'c1', 'name': 'Fruits & Vegetables', 'imageUrl': 'https://cdn-icons-png.flaticon.com/512/2329/2329865.png'},
      {'id': 'c2', 'name': 'Cooking Oil & Ghee', 'imageUrl': 'https://cdn-icons-png.flaticon.com/512/5346/5346124.png'},
      {'id': 'c3', 'name': 'Meat & Fish', 'imageUrl': 'https://cdn-icons-png.flaticon.com/512/1041/1041300.png'},
      {'id': 'c4', 'name': 'Bakery & Snacks', 'imageUrl': 'https://cdn-icons-png.flaticon.com/512/3014/3014502.png'},
      {'id': 'c5', 'name': 'Dairy & Eggs', 'imageUrl': 'https://cdn-icons-png.flaticon.com/512/2674/2674505.png'},
      {'id': 'c6', 'name': 'Beverages', 'imageUrl': 'https://cdn-icons-png.flaticon.com/512/3121/3121768.png'},
    ];

    // ২. প্রোডাক্ট লিস্ট (৬০টি আইটেম)
    List<Map<String, dynamic>> products = [
      // --- Fruits & Veg (c1 - 10 items) ---
      {'categoryId': 'c1', 'name': 'Organic Banana', 'price': 80, 'unit': '7pcs', 'imageUrl': 'https://images.unsplash.com/photo-1571771894821-ad9b58a32947?w=500&q=80', 'description': 'Fresh organic bananas.'},
      {'categoryId': 'c1', 'name': 'Red Apple', 'price': 280, 'unit': '1kg', 'imageUrl': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6fac6?w=500&q=80', 'description': 'Sweet crunchy apples.'},
      {'categoryId': 'c1', 'name': 'Bell Pepper', 'price': 150, 'unit': '500g', 'imageUrl': 'https://images.unsplash.com/photo-1563513673312-404f88ae9c2c?w=500&q=80', 'description': 'Fresh bell peppers.'},
      {'categoryId': 'c1', 'name': 'Fresh Ginger', 'price': 60, 'unit': '250g', 'imageUrl': 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=500&q=80', 'description': 'Strong organic ginger.'},
      {'categoryId': 'c1', 'name': 'Carrot', 'price': 90, 'unit': '1kg', 'imageUrl': 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=500&q=80', 'description': 'Fresh orange carrots.'},
      {'categoryId': 'c1', 'name': 'Broccoli', 'price': 120, 'unit': '500g', 'imageUrl': 'https://images.unsplash.com/photo-1459411621453-7b03977f4bef?w=500&q=80', 'description': 'Healthy green broccoli.'},
      {'categoryId': 'c1', 'name': 'Tomato', 'price': 70, 'unit': '1kg', 'imageUrl': 'https://images.unsplash.com/photo-1546473427-e1ad6c6a218f?w=500&q=80', 'description': 'Ripe farm tomatoes.'},
      {'categoryId': 'c1', 'name': 'Spinach', 'price': 40, 'unit': '1 bunch', 'imageUrl': 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=500&q=80', 'description': 'Fresh leafy spinach.'},
      {'categoryId': 'c1', 'name': 'Mango', 'price': 350, 'unit': '1kg', 'imageUrl': 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=500&q=80', 'description': 'Sweet seasonal mangoes.'},
      {'categoryId': 'c1', 'name': 'Potato', 'price': 50, 'unit': '1kg', 'imageUrl': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&q=80', 'description': 'Premium large potatoes.'},

      // --- Cooking Oil & Ghee (c2 - 10 items) ---
      {'categoryId': 'c2', 'name': 'Sunflower Oil', 'price': 950, 'unit': '5L', 'imageUrl': 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500&q=80', 'description': 'Refined healthy oil.'},
      {'categoryId': 'c2', 'name': 'Desi Ghee', 'price': 1200, 'unit': '1kg', 'imageUrl': 'https://images.unsplash.com/photo-1589927986089-35812388d1f4?w=500&q=80', 'description': 'Pure organic cow ghee.'},
      {'categoryId': 'c2', 'name': 'Olive Oil', 'price': 1400, 'unit': '1L', 'imageUrl': 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500&q=80', 'description': 'Extra virgin olive oil.'},
      {'categoryId': 'c2', 'name': 'Mustard Oil', 'price': 220, 'unit': '1L', 'imageUrl': 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500&q=80', 'description': 'Strong aroma mustard oil.'},
      {'categoryId': 'c2', 'name': 'Coconut Oil', 'price': 450, 'unit': '500ml', 'imageUrl': 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500&q=80', 'description': 'Pure edible coconut oil.'},
      {'categoryId': 'c2', 'name': 'Soybean Oil', 'price': 180, 'unit': '1L', 'imageUrl': 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500&q=80', 'description': 'Refined soybean oil.'},
      {'categoryId': 'c2', 'name': 'Butter', 'price': 400, 'unit': '500g', 'imageUrl': 'https://images.unsplash.com/photo-1589927986089-35812388d1f4?w=500&q=80', 'description': 'Salted farm butter.'},
      {'categoryId': 'c2', 'name': 'Canola Oil', 'price': 200, 'unit': '1L', 'imageUrl': 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500&q=80', 'description': 'Heart healthy oil.'},
      {'categoryId': 'c2', 'name': 'Vegetable Ghee', 'price': 180, 'unit': '1kg', 'imageUrl': 'https://images.unsplash.com/photo-1589927986089-35812388d1f4?w=500&q=80', 'description': 'Dalda vegetable ghee.'},
      {'categoryId': 'c2', 'name': 'Peanut Oil', 'price': 300, 'unit': '1L', 'imageUrl': 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500&q=80', 'description': 'Pure peanut oil.'},

      // --- Meat & Fish (c3 - 10 items) ---
      {'categoryId': 'c3', 'name': 'Beef Chuck', 'price': 750, 'unit': '1kg', 'imageUrl': 'https://images.unsplash.com/photo-1603048297172-c92544798d5e?w=500&q=80', 'description': 'Fresh premium beef.'},
      {'categoryId': 'c3', 'name': 'Chicken Breast', 'price': 350, 'unit': '1kg', 'imageUrl': 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=500&q=80', 'description': 'Skinless chicken breast.'},
      {'categoryId': 'c3', 'name': 'Salmon Fillet', 'price': 2200, 'unit': '1kg', 'imageUrl': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=500&q=80', 'description': 'Atlantic fresh salmon.'},
      {'categoryId': 'c3', 'name': 'Mutton Leg', 'price': 1100, 'unit': '1kg', 'imageUrl': 'https://images.unsplash.com/photo-1603048297172-c92544798d5e?w=500&q=80', 'description': 'Fresh mutton leg piece.'},
      {'categoryId': 'c3', 'name': 'Shrimp', 'price': 800, 'unit': '1kg', 'imageUrl': 'https://images.unsplash.com/photo-1559737558-2f5a35f4523b?w=500&q=80', 'description': 'Large fresh river shrimp.'},
      {'categoryId': 'c3', 'name': 'Duck Meat', 'price': 500, 'unit': '1kg', 'imageUrl': 'https://images.unsplash.com/photo-1603048297172-c92544798d5e?w=500&q=80', 'description': 'Fresh local duck meat.'},
      {'categoryId': 'c3', 'name': 'Rohu Fish', 'price': 450, 'unit': '1kg', 'imageUrl': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=500&q=80', 'description': 'Fresh river rohu fish.'},
      {'categoryId': 'c3', 'name': 'Chicken Wings', 'price': 300, 'unit': '1kg', 'imageUrl': 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=500&q=80', 'description': 'Spicy chicken wings.'},
      {'categoryId': 'c3', 'name': 'Beef Bone-in', 'price': 650, 'unit': '1kg', 'imageUrl': 'https://images.unsplash.com/photo-1603048297172-c92544798d5e?w=500&q=80', 'description': 'Fresh beef with bone.'},
      {'categoryId': 'c3', 'name': 'Tuna Steak', 'price': 1500, 'unit': '1kg', 'imageUrl': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=500&q=80', 'description': 'Premium tuna steak.'},

      // --- Bakery & Snacks (c4 - 10 items) ---
      {'categoryId': 'c4', 'name': 'Egg Pasta', 'price': 180, 'unit': '500g', 'imageUrl': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=500&q=80', 'description': 'Italian egg pasta.'},
      {'categoryId': 'c4', 'name': 'Potato Chips', 'price': 50, 'unit': '100g', 'imageUrl': 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=500&q=80', 'description': 'Crispy salted chips.'},
      {'categoryId': 'c4', 'name': 'White Bread', 'price': 60, 'unit': '400g', 'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&q=80', 'description': 'Fresh sliced bread.'},
      {'categoryId': 'c4', 'name': 'Cookies', 'price': 120, 'unit': '200g', 'imageUrl': 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=500&q=80', 'description': 'Choco-chip cookies.'},
      {'categoryId': 'c4', 'name': 'Muffins', 'price': 200, 'unit': '4pcs', 'imageUrl': 'https://images.unsplash.com/photo-1558303420-f814d8a590f5?w=500&q=80', 'description': 'Vanilla chocolate muffins.'},
      {'categoryId': 'c4', 'name': 'Popcorn', 'price': 80, 'unit': '150g', 'imageUrl': 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=500&q=80', 'description': 'Butter salted popcorn.'},
      {'categoryId': 'c4', 'name': 'Oats', 'price': 400, 'unit': '1kg', 'imageUrl': 'https://images.unsplash.com/photo-1586439702132-054593457193?w=500&q=80', 'description': 'Quick cooking oats.'},
      {'categoryId': 'c4', 'name': 'Chocolate Bar', 'price': 150, 'unit': '1pc', 'imageUrl': 'https://images.unsplash.com/photo-1511381939415-e44015466834?w=500&q=80', 'description': 'Dark milk chocolate.'},
      {'categoryId': 'c4', 'name': 'Noodles', 'price': 100, 'unit': '4pcs', 'imageUrl': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500&q=80', 'description': 'Instant masala noodles.'},
      {'categoryId': 'c4', 'name': 'Mixed Nuts', 'price': 600, 'unit': '500g', 'imageUrl': 'https://images.unsplash.com/photo-1511067007398-7e4b90cfa4bc?w=500&q=80', 'description': 'Healthy mixed nuts.'},

      // --- Dairy & Eggs (c5 - 10 items) ---
      {'categoryId': 'c5', 'name': 'Brown Eggs', 'price': 150, 'unit': '12pcs', 'imageUrl': 'https://images.unsplash.com/photo-1518569190558-299390fb2021?w=500&q=80', 'description': 'Fresh brown eggs.'},
      {'categoryId': 'c5', 'name': 'Cheese Block', 'price': 450, 'unit': '250g', 'imageUrl': 'https://images.unsplash.com/photo-1485962391905-dc37bc361994?w=500&q=80', 'description': 'Cheddar cheese block.'},
      {'categoryId': 'c5', 'name': 'Fresh Milk', 'price': 90, 'unit': '1L', 'imageUrl': 'https://images.unsplash.com/photo-1550583724-1255d1426639?w=500&q=80', 'description': 'Pasteurized whole milk.'},
      {'categoryId': 'c5', 'name': 'Yogurt', 'price': 120, 'unit': '500g', 'imageUrl': 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500&q=80', 'description': 'Creamy sour yogurt.'},
      {'categoryId': 'c5', 'name': 'Sour Cream', 'price': 250, 'unit': '200g', 'imageUrl': 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500&q=80', 'description': 'Fresh sour cream.'},
      {'categoryId': 'c5', 'name': 'Greek Yogurt', 'price': 300, 'unit': '400g', 'imageUrl': 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500&q=80', 'description': 'High protein yogurt.'},
      {'categoryId': 'c5', 'name': 'Cottage Cheese', 'price': 350, 'unit': '250g', 'imageUrl': 'https://images.unsplash.com/photo-1485962391905-dc37bc361994?w=500&q=80', 'description': 'Fresh paneer cheese.'},
      {'categoryId': 'c5', 'name': 'Ice Cream', 'price': 500, 'unit': '1L', 'imageUrl': 'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?w=500&q=80', 'description': 'Vanilla ice cream.'},
      {'categoryId': 'c5', 'name': 'Whipped Cream', 'price': 400, 'unit': '250ml', 'imageUrl': 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500&q=80', 'description': 'Creamy whipped cream.'},
      {'categoryId': 'c5', 'name': 'Mozzarella', 'price': 600, 'unit': '250g', 'imageUrl': 'https://images.unsplash.com/photo-1485962391905-dc37bc361994?w=500&q=80', 'description': 'Pizza mozzarella cheese.'},

      // --- Beverages (c6 - 10 items) ---
      {'categoryId': 'c6', 'name': 'Diet Coke', 'price': 60, 'unit': '355ml', 'imageUrl': 'https://images.unsplash.com/photo-1543253687-c931c8e01820?w=500&q=80', 'description': 'Sugar-free cola.'},
      {'categoryId': 'c6', 'name': 'Sprite Can', 'price': 50, 'unit': '325ml', 'imageUrl': 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=500&q=80', 'description': 'Lemon-lime soda.'},
      {'categoryId': 'c6', 'name': 'Orange Juice', 'price': 250, 'unit': '2L', 'imageUrl': 'https://images.unsplash.com/photo-1613478223719-2ab802602423?w=500&q=80', 'description': 'Pure orange juice.'},
      {'categoryId': 'c6', 'name': 'Pepsi Can', 'price': 50, 'unit': '330ml', 'imageUrl': 'https://images.unsplash.com/photo-1543253687-c931c8e01820?w=500&q=80', 'description': 'Classic Pepsi flavor.'},
      {'categoryId': 'c6', 'name': 'Cold Coffee', 'price': 150, 'unit': '250ml', 'imageUrl': 'https://images.unsplash.com/photo-1559496417-e7f25cb247f3?w=500&q=80', 'description': 'Brewed cold coffee.'},
      {'categoryId': 'c6', 'name': 'Mineral Water', 'price': 20, 'unit': '500ml', 'imageUrl': 'https://images.unsplash.com/photo-1523362628742-0c582e5e81e0?w=500&q=80', 'description': 'Pure drinking water.'},
      {'categoryId': 'c6', 'name': 'Energy Drink', 'price': 180, 'unit': '250ml', 'imageUrl': 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=500&q=80', 'description': 'Boost your energy.'},
      {'categoryId': 'c6', 'name': 'Lemon Tea', 'price': 120, 'unit': '500ml', 'imageUrl': 'https://images.unsplash.com/photo-1613478223719-2ab802602423?w=500&q=80', 'description': 'Iced lemon tea.'},
      {'categoryId': 'c6', 'name': 'Apple Juice', 'price': 200, 'unit': '1L', 'imageUrl': 'https://images.unsplash.com/photo-1613478223719-2ab802602423?w=500&q=80', 'description': 'Fresh pressed apple juice.'},
      {'categoryId': 'c6', 'name': 'Club Soda', 'price': 40, 'unit': '300ml', 'imageUrl': 'https://images.unsplash.com/photo-1523362628742-0c582e5e81e0?w=500&q=80', 'description': 'Sparkling club soda.'},
    ];

    try {
      // ক্যাটাগরি আপলোড
      for (var cat in categories) {
        await _db.collection('categories').doc(cat['id']).set(cat);
      }
      // প্রোডাক্ট আপলোড
      // পুশ করার সময় এটি নিশ্চিত করো
      for (var prod in products) {
        DocumentReference docRef = _db.collection('products').doc();
        prod['id'] = docRef.id;
        // ক্যাটাগরি নামটাও সেভ করছি যেন ফিল্টার করতে সুবিধা হয়
        prod['categoryName'] = categories.firstWhere((c) => c['id'] == prod['categoryId'])['name'];
        await docRef.set(prod);
      }
      print("✅ Successfully uploaded 60 products!");
    } catch (e) {
      print("❌ Error: $e");
    }
  }
}