import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'order_history_page.dart';

class ProductPage extends StatefulWidget {
  final String userId;

  const ProductPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> allProducts = [
    {'name': 'Water', 'price': 20, 'icon': Icons.water_drop, 'color': Colors.blue},
    {'name': 'Soda', 'price': 35, 'icon': Icons.local_drink, 'color': Colors.brown},
    {'name': 'Juice', 'price': 50, 'icon': Icons.local_bar, 'color': Colors.orange},
    {'name': 'Milk', 'price': 45, 'icon': Icons.coffee, 'color': Colors.grey},
    {'name': 'Tea', 'price': 30, 'icon': Icons.emoji_food_beverage, 'color': Colors.green},
    {'name': 'Coffee', 'price': 40, 'icon': Icons.coffee_maker, 'color': Colors.brown[700]!},
    {'name': 'Energy Drink', 'price': 60, 'icon': Icons.battery_charging_full, 'color': Colors.red},
    {'name': 'Smoothie', 'price': 70, 'icon': Icons.blender, 'color': Colors.pink},
    {'name': 'Lemonade', 'price': 40, 'icon': Icons.local_drink, 'color': Colors.yellow},
    {'name': 'Iced Tea', 'price': 35, 'icon': Icons.ice_skating, 'color': Colors.teal},
  ];

  List<Map<String, dynamic>> displayedProducts = [];
  final List<int> refillOptions = [100, 250, 500, 1000];
  TextEditingController searchController = TextEditingController();
  Set<String> favorites = {};
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    displayedProducts = List.from(allProducts);
    _loadFavorites();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();
    super.dispose();
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
        title: Text(AppLocalizations.of(context)!.selectProduct),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showOrderHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.searchProducts,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              onChanged: searchProducts,
            ),
          ),
          Expanded(
            child: AnimationLimiter(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: displayedProducts.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: _buildProductCard(displayedProducts[index]),
                      ),
                    ),
                  );
                },
              ),
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
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: Icon(
                      product['icon'],
                      size: 60,
                      color: product['color'],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
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
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹${product['price']}',
                    style: const TextStyle(fontSize: 14, color: Colors.green),
                  ),
                ],
              ),
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.75,
          expand: false,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.selectRefillAmount(product['name']),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: refillOptions.length,
                      itemBuilder: (context, index) {
                        final amount = refillOptions[index];
                        return ListTile(
                          title: Text('$amount ml'),
                          trailing: Text('₹${(product['price'] * amount / 500).round()}'),
                          onTap: () => _placeOrder(product, amount),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _placeOrder(Map<String, dynamic> product, int amount) {
    FirebaseFirestore.instance.collection('orders').add({
      'userId': widget.userId,
      'product': product['name'],
      'amount': amount,
      'price': (product['price'] * amount / 500).toDouble(),
      'timestamp': FieldValue.serverTimestamp(),
    }).then((_) {
      Navigator.of(context).pop(); // Close bottom sheet
      _showOrderConfirmation();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorPlacingOrder(error.toString()))),
      );
    });
  }

  void _showOrderConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.orderPlaced),
          content: Text(AppLocalizations.of(context)!.proceedToKiosk),
          actions: [
            TextButton(
              child: const Text("OK"),
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
        builder: (context) => OrderHistoryPage(userId: widget.userId),
      ),
    );
  }
}