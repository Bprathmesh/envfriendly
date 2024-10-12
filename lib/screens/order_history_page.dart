import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
              return _buildOrderTile(order);
            },
          );
        },
      ),
    );
  }

 Widget _buildOrderTile(DocumentSnapshot order) {
  // Safely cast the order data to a Map<String, dynamic>
  final data = order.data() as Map<String, dynamic>;

  // Safely get values from the document, providing defaults if fields are missing
  String productName = data.containsKey('product') ? data['product'] : 'Unknown Product';
  int amount = data.containsKey('amount') ? data['amount'] : 0;

  // Check if 'price' field exists and is not null before accessing it
  double price = (data.containsKey('price') && data['price'] != null) ? data['price'].toDouble() : 0.0;

  // Check if 'timestamp' field exists before accessing it
  Timestamp? timestamp = data.containsKey('timestamp') ? data['timestamp'] as Timestamp? : null;

  return ListTile(
    title: Text(productName),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$amount ml'),
        if (timestamp != null)
          Text(DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate())),
      ],
    ),
    trailing: Text('₹${price.toStringAsFixed(2)}'),
  );
}

}