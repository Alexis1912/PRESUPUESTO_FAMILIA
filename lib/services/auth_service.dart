import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _db.collection("usuarios").doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Future<UserModel> registerUser(
      String nombre, String email, String pass) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: pass,
    );

    final user = UserModel(
      uid: cred.user!.uid,
      nombre: nombre,
      rol: "miembro",
    );

    await _db.collection("usuarios").doc(user.uid).set(user.toMap());
    return user;
  }

  Future<UserModel?> login(String email, String pass) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: pass,
    );

    return getUserData(cred.user!.uid);
  }

  Future<void> logout() => _auth.signOut();
}
