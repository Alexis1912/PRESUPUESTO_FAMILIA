import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nombre = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();

  final auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crear cuenta")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(controller: nombre, decoration: InputDecoration(labelText: "Nombre")),
            TextField(controller: email, decoration: InputDecoration(labelText: "Correo")),
            TextField(controller: pass, obscureText: true, decoration: InputDecoration(labelText: "Contraseña")),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final user = await auth.registerUser(nombre.text, email.text, pass.text);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
                );
              },
              child: const Text("Registrar"),
            )
          ],
        ),
      ),
    );
  }
}
