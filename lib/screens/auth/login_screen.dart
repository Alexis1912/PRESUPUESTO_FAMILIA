import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();

  final auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text(
                "Iniciar Sesión",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              TextField(
                controller: email,
                decoration: InputDecoration(labelText: "Correo"),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: pass,
                obscureText: true,
                decoration: InputDecoration(labelText: "Contraseña"),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {
                  final user = await auth.login(email.text, pass.text);
                  if (user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(user: user),
                      ),
                    );
                  }
                },
                child: const Text("Ingresar"),
              ),

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
