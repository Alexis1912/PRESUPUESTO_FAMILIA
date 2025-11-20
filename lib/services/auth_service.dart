import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get userChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _firebaseMessage(e);
    } catch (e) {
      return "Error desconocido: ${e.toString()}";
    }
  }

  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _firebaseMessage(e);
    } catch (e) {
      return "Error desconocido: ${e.toString()}";
    }
  }

  Future<String?> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
      return null;
    } catch (e) {
      return "Error cerrando sesión: ${e.toString()}";
    }
  }

  String _firebaseMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "Usuario no registrado";
      case 'wrong-password':
        return "Contraseña incorrecta";
      case 'invalid-email':
        return "Correo inválido";
      case 'email-already-in-use':
        return "Este correo ya está registrado";
      case 'weak-password':
        return "Contraseña muy débil";
      default:
        return e.message ?? "Error de autenticación desconocido";
    }
  }
}
