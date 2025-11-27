import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
        child: Text("Error al cargar datos: ${snapshot.error}"),
      );
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(child: Text("No hay movimientos registrados"));
    }

    final docs = snapshot.data!.docs;

    double ingresos = 0;
    double egresos = 0;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final monto = (data["monto"] ?? 0).toDouble();
      final tipo = data["tipo"];

      if (tipo == "ingreso") ingresos += monto;
      if (tipo == "egreso") egresos += monto;
    }

    final balance = ingresos - egresos;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "Resumen General",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // ===================== GRAFICO DE BARRAS =====================
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text("Ingresos");
                            case 1:
                              return const Text("Egresos");
                            default:
                              return const SizedBox();
                          }
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: ingresos,
                          color: Colors.green,
                          width: 25,
                          borderRadius: BorderRadius.circular(4),
                        )
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: egresos,
                          color: Colors.red,
                          width: 25,
                          borderRadius: BorderRadius.circular(4),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        _buildCard("Total Ingresos", ingresos, Colors.green),
        _buildCard("Total Egresos", egresos, Colors.red),
        _buildCard("Balance", balance,
            balance >= 0 ? Colors.green : Colors.red),

        const SizedBox(height: 25),

        const Text(
          "Últimos movimientos",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        for (int i = 0; i < docs.length && i < 5; i++)
          _buildMovimientoItem(docs[i]),
      ],
    );
  },
);

}

// ===================== TARJETAS =====================
Widget _buildCard(String titulo, double monto, Color color) {
return Card(
color: color.withOpacity(0.12),
elevation: 3,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
child: ListTile(
leading: Icon(Icons.circle, color: color),
title: Text(titulo),
trailing: Text(
"Bs. ${monto.toStringAsFixed(2)}",
style: TextStyle(
fontWeight: FontWeight.bold,
color: color,
),
),
),
);
}

// ===================== MOVIMIENTOS =====================
Widget _buildMovimientoItem(QueryDocumentSnapshot doc) {
final data = doc.data() as Map<String, dynamic>;
final tipo = data["tipo"];
final categoria = data["categoria"];
final monto = data["monto"];
final descripcion = data["descripcion"];
final fecha = (data["fecha"] as Timestamp).toDate();

return Card(
  child: ListTile(
    leading: CircleAvatar(
      backgroundColor: tipo == "ingreso" ? Colors.green : Colors.red,
      child: Icon(
        tipo == "ingreso" ? Icons.arrow_downward : Icons.arrow_upward,
        color: Colors.white,
      ),
    ),
    title: Text("$categoria - Bs. $monto"),
    subtitle: Text(descripcion),
    trailing: Text("${fecha.day}/${fecha.month}/${fecha.year}"),
  ),
);


}
}
