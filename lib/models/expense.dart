import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String id;
  double amount;
  String description;
  String category;
  Timestamp createdAt;

  Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "amount": amount,
      "description": description,
      "category": category,
      "createdAt": createdAt,
    };
  }

  factory Expense.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      amount: (d["amount"] as num).toDouble(),
      description: d["description"] ?? '',
      category: d["category"] ?? '',
      createdAt: d["createdAt"] ?? Timestamp.now(),
    );
  }
}
