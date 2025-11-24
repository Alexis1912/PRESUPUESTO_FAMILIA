import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class RegistrarMovimientoScreen extends StatefulWidget {
  RegistrarMovimientoScreen({super.key});

  @override
  State<RegistrarMovimientoScreen> createState() => _RegistrarMovimientoScreenState();
}

class _RegistrarMovimientoScreenState extends State<RegistrarMovimientoScreen> {
  final TextEditingController montoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  String tipo = "ingreso";
  String categoria = "General";

  final List<String> categorias = [
    "Alimentación",
    "Transporte",
    "Servicios",
    "Salud",
    "Educación",
    "Entretenimiento",
    "General",
  ];

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Movimiento")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tipo de movimiento", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton(
              value: tipo,
              items: const [
                DropdownMenuItem(value: "ingreso", child: Text("Ingreso")),
                DropdownMenuItem(value: "egreso", child: Text("Egreso")),
              ],
              onChanged: (value) {
                setState(() {
                  tipo = value.toString();
                });
              },
            ),
            const SizedBox(height: 20),

            const Text("Categoría", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton(
              value: categoria,
              items: categorias
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  categoria = value.toString();
                });
              },
            ),
            const SizedBox(height: 20),

            TextField(
              controller: montoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Monto (Bs.)"),
            ),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: "Descripción"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (montoController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Ingrese un monto válido")),
                        );
                        return;
                      }

                      setState(() => loading = true);

                      final firestore = FirestoreService();

                      final error = await firestore.guardarMovimiento(
                        tipo: tipo,
                        categoria: categoria,
                        monto: double.tryParse(montoController.text) ?? 0.0,
                        descripcion: descripcionController.text,
                      );

                      setState(() => loading = false);

                      if (error == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Movimiento guardado en Firestore 🎉")),
                        );

                        // Espera corta para evitar errores en Web
                        await Future.delayed(const Duration(milliseconds: 200));

                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $error")),
                        );
                      }
                    },
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Guardar"),
            )
          ],
        ),
      ),
    );
  }
}
