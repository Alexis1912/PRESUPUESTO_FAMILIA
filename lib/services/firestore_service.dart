import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<String?> guardarMovimiento({
    required String tipo,
    required String categoria,
    required double monto,
    required String descripcion,
  }) async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;

      await db.collection('movimientos').add({
        "uid": uid,
        "tipo": tipo,
        "categoria": categoria,
        "monto": monto,
        "descripcion": descripcion,
        "fecha": DateTime.now(),
      });

      return null; // sin errores
    } catch (e) {
      return e.toString();
    }
  }
}
