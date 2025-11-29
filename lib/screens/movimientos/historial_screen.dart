import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HistorialScreen extends StatelessWidget {
  final String uid;

  const HistorialScreen({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("movimientos")
          .where("uid", isEqualTo: uid)
          .orderBy("fecha", descending: true)
          .snapshots(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No hay movimientos aún"));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final fecha = (data["fecha"] as Timestamp).toDate();

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: data["tipo"] == "ingreso" ? Colors.green : Colors.red,
                  child: Icon(
                    data["tipo"] == "ingreso" ? Icons.arrow_downward : Icons.arrow_upward,
                    color: Colors.white,
                  ),
                ),
                title: Text("${data['categoria']} - Bs. ${data['monto']}"),
                subtitle: Text("${data['descripcion']} \nAgregado por: ${data['usuario']}"),
                trailing: Text("${fecha.day}/${fecha.month}/${fecha.year}"),
              ),
            );
          },
        );
      },
    );
  }
}
