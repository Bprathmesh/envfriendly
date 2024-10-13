import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OrderHistoryPage extends StatelessWidget {
  final String userId;

  const OrderHistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(AppLocalizations.of(context)!.orderHistory),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.errorLoadingOrders,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      (context as Element).markNeedsBuild();
                    },
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.noOrderHistory,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          int totalAmount = snapshot.data!.docs.fold(0, (sum, doc) => sum + (doc['amount'] as int? ?? 0));
          double pollutionSaved = totalAmount * 0.01; // Assuming 0.01 kg of plastic saved per ml

          return Column(
            children: [
              _buildPollutionSavedCard(context, pollutionSaved),
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var order = snapshot.data!.docs[index];
                    return _buildOrderTile(order, context);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPollutionSavedCard(BuildContext context, double pollutionSaved) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.green[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.pollutionSaved,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${pollutionSaved.toStringAsFixed(2)} kg',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.plasticWasteSaved,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTile(DocumentSnapshot order, BuildContext context) {
    final data = order.data() as Map<String, dynamic>;

    String productName = data['product'] ?? AppLocalizations.of(context)!.unknownProduct;
    int amount = data['amount'] ?? 0;
    double price = (data['price'] != null) ? data['price'].toDouble() : 0.0;
    Timestamp? timestamp = data['timestamp'] as Timestamp?;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              productName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${AppLocalizations.of(context)!.amount}: $amount ml'),
                Text(
                  '${AppLocalizations.of(context)!.price}: ₹${price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            if (timestamp != null)
              Text(
                '${AppLocalizations.of(context)!.date}: ${DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate())}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            const SizedBox(height: 4),
            Text(
              '${AppLocalizations.of(context)!.plasticSaved}: ${(amount * 0.01).toStringAsFixed(2)} kg',
              style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}