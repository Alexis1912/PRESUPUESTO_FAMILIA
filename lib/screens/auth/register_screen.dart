import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key}); // Quitamos const

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Crear Cuenta")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: "Correo"),
            ),
            TextField(
              controller: pass,
              decoration: const InputDecoration(labelText: "Contraseña"),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      setState(() {
                        loading = true;
                        errorMessage = null;
                      });

                      final error = await auth.register(
                        email.text.trim(),
                        pass.text.trim(),
                      );

                      if (error != null) {
                        setState(() => errorMessage = error);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomeScreen(), // Quitamos const
                          ),
                        );
                      }

                      setState(() => loading = false);
                    },
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Registrar"),
            ),
          ],
        ),
      ),
    );
  }
}
