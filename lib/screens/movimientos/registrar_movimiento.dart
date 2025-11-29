import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegistrarMovimientoScreen extends StatefulWidget {
  final String uid;
  final String nombre;

  RegistrarMovimientoScreen({required this.uid, required this.nombre});

  @override
  State<RegistrarMovimientoScreen> createState() => _RegistrarMovimientoScreenState();
}

class _RegistrarMovimientoScreenState extends State<RegistrarMovimientoScreen> {
  final monto = TextEditingController();
  final descripcion = TextEditingController();
  String tipo = "ingreso";
  String categoria = "General";

  Future<void> guardarMovimiento() async {
    if (monto.text.isEmpty) return;

    await FirebaseFirestore.instance.collection("movimientos").add({
      "uid": widget.uid,
      "usuario": widget.nombre,
      "monto": double.parse(monto.text),
      "descripcion": descripcion.text,
      "categoria": categoria,
      "tipo": tipo,
      "fecha": Timestamp.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registrar Movimiento")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text("Tipo de movimiento", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: "ingreso", label: Text("Ingreso")),
                ButtonSegment(value: "egreso", label: Text("Egreso")),
              ],
              selected: {tipo},
              onSelectionChanged: (value) => setState(() => tipo = value.first),
            ),

            SizedBox(height: 25),

            TextField(
              controller: monto,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Monto (Bs.)"),
            ),

            SizedBox(height: 20),

            TextField(
              controller: descripcion,
              decoration: InputDecoration(labelText: "Descripción"),
            ),

            SizedBox(height: 20),

            DropdownButtonFormField(
              value: categoria,
              items: [
                "General",
                "Comida",
                "Transporte",
                "Servicios",
                "Salud",
                "Entretenimiento"
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => categoria = v!),
              decoration: InputDecoration(labelText: "Categoría"),
            ),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: guardarMovimiento,
              child: const Text("Guardar Movimiento"),
            )
          ],
        ),
      ),
    );
  }
}
