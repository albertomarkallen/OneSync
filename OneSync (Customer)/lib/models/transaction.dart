import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String transactionId;
  final String rfidId;
  final num price;
  final DateTime timestamp;

  Transaction({
    required this.transactionId,
    required this.rfidId,
    required this.price,
    required this.timestamp,
  });

  // Convert Firestore document to Transaction object
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Transaction(
      transactionId: doc.id,
      rfidId: data['rfid'] ?? '',
      price: data['totalPrice'] ?? 0,
      timestamp: (data['date'] as Timestamp).toDate(), 
    );
  }
}
