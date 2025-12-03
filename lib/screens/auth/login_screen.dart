import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool cargando = false;

  Future<void> login() async {
    setState(() => cargando = true);

    try {
      // 🔥 INICIO DE SESIÓN
      UserCredential cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      final uid = cred.user!.uid;

      // 🔥 OBTENER DATOS DEL USUARIO EN FIRESTORE
      final doc = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(uid)
          .get();

      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: el usuario no tiene datos en Firestore")),
        );
        return;
      }

      final user = UserModel.fromMap(doc.data()!);

      // 🔥 REDIRIGIR AL HOME
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al iniciar sesión: $e")),
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
                "Iniciar Sesión",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 40),

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

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: cargando ? null : login,
                child: cargando
                    ? CircularProgressIndicator(color: Colors.white)
                    : const Text("Ingresar"),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterScreen()),
                  );
                },
                child: const Text("Crear cuenta"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
