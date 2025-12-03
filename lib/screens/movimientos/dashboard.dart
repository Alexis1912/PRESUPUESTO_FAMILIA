import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  final String uid;

  const Dashboard({super.key, required this.uid});

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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 20),
                  Text(
                    "Error al cargar datos",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 20),
                const Text(
                  "Aún no hay movimientos registrados",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  "Comienza agregando tu primer movimiento",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        double ingresos = 0;
        double egresos = 0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          double monto = (data["monto"] ?? 0).toDouble();
          String tipo = data["tipo"] ?? "";

          if (tipo == "ingreso") ingresos += monto;
          if (tipo == "egreso") egresos += monto;
        }

        double balance = ingresos - egresos;

        return RefreshIndicator(
          onRefresh: () async {
            // Forzar recarga
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                "Resumen General",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _infoCard("Total Ingresos", ingresos, Colors.green),
              _infoCard("Total Egresos", egresos, Colors.red),
              _infoCard(
                "Balance Disponible",
                balance,
                balance >= 0 ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 25),
              _buildBarChart(ingresos, egresos),
              const SizedBox(height: 30),
              const Text(
                "Últimos movimientos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              for (int i = 0; i < docs.length && i < 5; i++)
                _buildMovimientoItem(docs[i]),
            ],
          ),
        );
      },
    );
  }

  Widget _infoCard(String titulo, double monto, Color color) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(Icons.attach_money, color: color, size: 28),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Text(
          "Bs. ${monto.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(double ingresos, double egresos) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: ingresos > 0 ? ingresos : 1,
                      width: 30,
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: egresos > 0 ? egresos : 1,
                      width: 30,
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              ],
              titlesData: FlTitlesData(
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text("Ingresos"),
                          );
                        case 1:
                          return const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text("Egresos"),
                          );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovimientoItem(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final fecha = (data["fecha"] as Timestamp?)?.toDate() ?? DateTime.now();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor:
              data["tipo"] == "ingreso" ? Colors.green : Colors.red,
          child: Icon(
            data["tipo"] == "ingreso"
                ? Icons.arrow_downward
                : Icons.arrow_upward,
            color: Colors.white,
          ),
        ),
        title: Text(
          "${data['categoria'] ?? 'Sin categoría'} - Bs. ${(data['monto'] ?? 0).toStringAsFixed(2)}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data["descripcion"] ?? "Sin descripción"),
            const SizedBox(height: 3),
            Text(
              "Agregado por: ${data["usuario"] ?? "Desconocido"}",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
        trailing: Text(
          "${fecha.day}/${fecha.month}/${fecha.year}",
          style: TextStyle(color: Colors.grey[700]),
        ),
      ),
    );
  }
}