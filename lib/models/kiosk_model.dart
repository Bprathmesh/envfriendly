import 'package:cloud_firestore/cloud_firestore.dart';

class Kiosk {
  final String id;
  final String name;
  final GeoPoint location;
  final List<String> availableProducts;

  Kiosk({
    required this.id,
    required this.name,
    required this.location,
    required this.availableProducts,
  });

  factory Kiosk.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Kiosk(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? GeoPoint(0, 0),
      availableProducts: List<String>.from(data['availableProducts'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'availableProducts': availableProducts,
    };
  }
}