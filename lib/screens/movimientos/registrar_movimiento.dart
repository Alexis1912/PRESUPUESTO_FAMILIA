import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrarMovimientoScreen extends StatefulWidget {
  final String uid;
  final String nombre;

  const RegistrarMovimientoScreen({
    super.key,
    required this.uid,
    required this.nombre,
  });

  @override
  State<RegistrarMovimientoScreen> createState() =>
      _RegistrarMovimientoScreenState();
}

class _RegistrarMovimientoScreenState extends State<RegistrarMovimientoScreen> {
  final TextEditingController monto = TextEditingController();
  final TextEditingController descripcion = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String tipo = "ingreso";
  String categoria = "General";
  bool isLoading = false;

  Future<void> guardarMovimiento() async {
    if (!_formKey.currentState!.validate()) return;

    final montoDouble = double.tryParse(monto.text.trim());
    if (montoDouble == null || montoDouble <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Monto inválido"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection("movimientos").add({
        "uid": widget.uid,
        "usuario": widget.nombre,
        "monto": montoDouble,
        "descripcion": descripcion.text.trim().isEmpty
            ? "Sin descripción"
            : descripcion.text.trim(),
        "categoria": categoria,
        "tipo": tipo,
        "fecha": Timestamp.now(),
      });

      // Guardar navegador antes de operaciones
      if (!mounted) return;
      final nav = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      messenger.showSnackBar(
        const SnackBar(
          content: Text("✓ Movimiento guardado"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );

      // Esperar un momento para que se vea el mensaje
      await Future.delayed(const Duration(milliseconds: 300));

      // Cerrar pantalla y retornar true
      nav.pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    monto.dispose();
    descripcion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Movimiento"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  const Text(
                    "Tipo de movimiento",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: "ingreso",
                        label: Text("Ingreso"),
                        icon: Icon(Icons.arrow_downward),
                      ),
                      ButtonSegment(
                        value: "egreso",
                        label: Text("Egreso"),
                        icon: Icon(Icons.arrow_upward),
                      ),
                    ],
                    selected: {tipo},
                    onSelectionChanged: (v) {
                      if (mounted) {
                        setState(() => tipo = v.first);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: monto,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Monto (Bs.)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                      prefixText: "Bs. ",
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Ingresa un monto";
                      }
                      final num = double.tryParse(v);
                      if (num == null || num <= 0) {
                        return "Monto debe ser mayor a 0";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: descripcion,
                    decoration: const InputDecoration(
                      labelText: "Descripción (opcional)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: categoria,
                    decoration: const InputDecoration(
                      labelText: "Categoría",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: [
                      "General",
                      "Comida",
                      "Transporte",
                      "Servicios",
                      "Salud",
                      "Entretenimiento",
                      "Educación",
                      "Vivienda",
                    ]
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (mounted && v != null) {
                        setState(() => categoria = v);
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : guardarMovimiento,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      isLoading ? "Guardando..." : "Guardar Movimiento",
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}