import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductPage extends StatelessWidget {
  final List<Map<String, dynamic>> products = [
    {'name': 'Product 1', 'price': 10.0},
    {'name': 'Product 2', 'price': 15.0},
    {'name': 'Product 3', 'price': 20.0},
  ];

  final List<int> refillOptions = [100, 250, 500, 1000];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Product')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(products[index]['name']),
            subtitle: Text('\$${products[index]['price']}'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Select Refill Amount'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: refillOptions.map((amount) {
                        return ListTile(
                          title: Text('$amount ml'),
                          onTap: () {
                            // Save order to Firestore
                            FirebaseFirestore.instance.collection('orders').add({
                              'product': products[index]['name'],
                              'amount': amount,
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Order placed successfully!')),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}