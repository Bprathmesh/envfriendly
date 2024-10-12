import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String userId;
  final String productId;
  final int amount;
  final DateTime timestamp;

  Order({
    required this.id,
    required this.userId,
    required this.productId,
    required this.amount,
    required this.timestamp,
  });

  factory Order.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      amount: data['amount'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productId': productId,
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}