import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_model.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nombre = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool cargando = false;

  String rol = "miembro"; // valor por defecto

  Future<void> registrar() async {
    if (nombre.text.isEmpty || email.text.isEmpty || password.text.isEmpty) return;

    setState(() => cargando = true);

    try {
      // 🔥 CREAR CUENTA EN FIREBASE AUTH
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      final uid = cred.user!.uid;

      // 🔥 GUARDAR EN FIRESTORE
      UserModel user = UserModel(
        uid: uid,
        nombre: nombre.text.trim(),
        email: email.text.trim(),
        rol: rol,
      );

      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(uid)
          .set(user.toMap());

      // 🔥 IR AL HOME
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al crear cuenta: $e")),
      );
    }

    setState(() => cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 450,
          child: ListView(
            padding: const EdgeInsets.all(20),
            shrinkWrap: true,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Crear Cuenta",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: nombre,
                decoration: InputDecoration(labelText: "Nombre"),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: email,
                decoration: InputDecoration(labelText: "Correo"),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: password,
                decoration: InputDecoration(labelText: "Contraseña"),
                obscureText: true,
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField(
                value: rol,
                items: const [
                  DropdownMenuItem(value: "admin", child: Text("Administrador")),
                  DropdownMenuItem(value: "miembro", child: Text("Miembro")),
                ],
                onChanged: (v) => setState(() => rol = v!),
                decoration: InputDecoration(labelText: "Rol de usuario"),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: cargando ? null : registrar,
                child: cargando
                    ? CircularProgressIndicator(color: Colors.white)
                    : const Text("Crear cuenta"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
