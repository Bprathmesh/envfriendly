// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> allProducts = [
    {'name': 'Water', 'price': 20, 'icon': Icons.water_drop},
    {'name': 'Soda', 'price': 35, 'icon': Icons.local_drink},
    {'name': 'Juice', 'price': 50, 'icon': Icons.local_bar},
    {'name': 'Milk', 'price': 45, 'icon': Icons.coffee},
    {'name': 'Tea', 'price': 30, 'icon': Icons.emoji_food_beverage},
    {'name': 'Coffee', 'price': 40, 'icon': Icons.coffee_maker},
    {'name': 'Energy Drink', 'price': 60, 'icon': Icons.battery_charging_full},
    {'name': 'Smoothie', 'price': 70, 'icon': Icons.blender},
    {'name': 'Lemonade', 'price': 40, 'icon': Icons.local_drink},
    {'name': 'Iced Tea', 'price': 35, 'icon': Icons.ice_skating},
  ];

  List<Map<String, dynamic>> displayedProducts = [];
  final List<int> refillOptions = [100, 250, 500, 1000];
  TextEditingController searchController = TextEditingController();
  Set<String> favorites = {};

  @override
  void initState() {
    super.initState();
    displayedProducts = List.from(allProducts);
    _loadFavorites();
  }

  void _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = prefs.getStringList('favorites')?.toSet() ?? {};
    });
  }

  void _saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorites', favorites.toList());
  }

  void searchProducts(String query) {
    setState(() {
      displayedProducts = allProducts
          .where((product) =>
              product['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Product'),
        backgroundColor: Colors.deepPurple,
        actions: const [
          // IconButton(
          //   icon: const Icon(Icons.favorite),
          //   onPressed: _showOrderHistory,
          // ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Products',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              onChanged: searchProducts,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: displayedProducts.length,
              itemBuilder: (context, index) {
                return _buildProductCard(displayedProducts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
  bool isFavorite = favorites.contains(product['name']);
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: InkWell(
      onTap: () => _showRefillOptions(product),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              // Align product icon at the top
              Align(
                alignment: Alignment.topCenter,
                child: Icon(product['icon'], size: 50, color: Colors.deepPurple),
              ),
              // Positioned widget for the favorite icon at the bottom-right
              Positioned(
                right: 8,  // Position it slightly from the right edge
                bottom: 8, // Position it slightly from the bottom edge
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () => _toggleFavorite(product['name']),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            product['name'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${product['price']}',
            style: const TextStyle(fontSize: 16, color: Colors.green),
          ),
        ],
      ),
    ),
  );
}

  void _toggleFavorite(String productName) {
    setState(() {
      if (favorites.contains(productName)) {
        favorites.remove(productName);
      } else {
        favorites.add(productName);
      }
    });
    _saveFavorites();
  }

  void _showRefillOptions(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Refill Amount for ${product['name']}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...refillOptions.map((amount) => ListTile(
                    title: Text('$amount ml'),
                    trailing: Text('₹${(product['price'] * amount / 500).round()}'),
                    onTap: () => _placeOrder(product, amount),
                  )),
            ],
          ),
        );
      },
    );
  }

  void _placeOrder(Map<String, dynamic> product, int amount) {
    FirebaseFirestore.instance.collection('orders').add({
      'product': product['name'],
      'amount': amount,
      'price': (product['price'] * amount / 500).toDouble(),
      'timestamp': FieldValue.serverTimestamp(),
    }).then((_) {
      Navigator.of(context).pop(); // Close bottom sheet
      _showOrderConfirmation();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $error')),
      );
    });
  }

  void _showOrderConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Order Placed Successfully!'),
          content: const Text('Please proceed to the kiosk to collect your order.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showOrderHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OrderHistoryPage(),
      ),
    );
  }
}

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No order history'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var order = snapshot.data!.docs[index];
              return ListTile(
                title: Text(order['product']),
                subtitle: Text('${order['amount']} ml'),
                trailing: Text('₹${order['price']}'),
              );
            },
          );
        },
      ),
    );
  }
}