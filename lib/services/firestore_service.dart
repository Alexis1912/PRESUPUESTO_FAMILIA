import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener gastos en tiempo real
  Stream<List<Expense>> getExpenses() {
    return _db
        .collection("expenses")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Expense.fromDoc(doc)).toList());
  }

  // Agregar gasto
  Future<void> addExpense(Expense exp) async {
    await _db.collection("expenses").add(exp.toMap());
  }
}
