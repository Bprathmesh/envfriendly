import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final List<Map<String, dynamic>> allProducts = [
    {'name': 'Liquid Detergent', 'price': 20, 'icon': Icons.water_drop},
    {'name': 'Toothpaste', 'price': 35, 'icon': Icons.local_drink},
    {'name': 'Handwash', 'price': 50, 'icon': Icons.local_bar},
    {'name': 'Shampoo', 'price': 45, 'icon': Icons.coffee},
    {'name': 'Toilet Cleaner', 'price': 30, 'icon': Icons.emoji_food_beverage},
    {'name': 'Harpic', 'price': 40, 'icon': Icons.coffee_maker},
    {'name': 'Shower Gel', 'price': 60, 'icon': Icons.battery_charging_full},
    {'name': 'Red Harpic', 'price': 70, 'icon': Icons.blender},
    {'name': 'Cleaning Liquid', 'price': 40, 'icon': Icons.air_sharp},
    {'name': 'Lotion', 'price': 35, 'icon': Icons.ice_skating},
  ];

  List<Map<String, dynamic>> displayedProducts = [];
  final List<int> refillOptions = [100, 250, 500, 1000];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    displayedProducts = allProducts;
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _showRefillOptions(product),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(product['icon'], size: 50, color: Colors.deepPurple),
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
      'price': (product['price'] * amount / 500).round(),
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
}