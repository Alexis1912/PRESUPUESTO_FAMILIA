import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Ruta correcta
import 'movimientos/registrar_movimiento.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int paginaActual = 0;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final paginas = [
      Dashboard(uid: uid),
      RegistrarMovimientoScreen(),
      HistorialScreen(uid: uid),
      const Center(child: Text("Configuración (en construcción)")),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Presupuesto Familiar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),

      body: paginas[paginaActual],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: paginaActual,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey[700],
        onTap: (index) {
          setState(() => paginaActual = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: "Registrar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Historial",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Config",
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// DASHBOARD
//////////////////////////////////////////////////////////////////////////////

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

        /// Estado: Cargando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        /// Estado: Error
        if (snapshot.hasError) {
          return Center(
            child: Text("Error al cargar datos: ${snapshot.error}"),
          );
        }

        /// Estado: Sin datos
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No hay movimientos registrados todavía"),
          );
        }

        final docs = snapshot.data!.docs;

        double ingresos = 0;
        double egresos = 0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final monto = (data["monto"] ?? 0).toDouble();
          final tipo = data["tipo"] ?? "";

          if (tipo == "ingreso") ingresos += monto;
          if (tipo == "egreso") egresos += monto;
        }

        final balance = ingresos - egresos;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text(
                "Resumen General",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Card(
                color: Colors.greenAccent[100],
                child: ListTile(
                  leading: const Icon(Icons.arrow_downward, color: Colors.green),
                  title: const Text("Total Ingresos"),
                  trailing: Text("Bs. ${ingresos.toStringAsFixed(2)}"),
                ),
              ),

              Card(
                color: Colors.redAccent[100],
                child: ListTile(
                  leading: const Icon(Icons.arrow_upward, color: Colors.red),
                  title: const Text("Total Egresos"),
                  trailing: Text("Bs. ${egresos.toStringAsFixed(2)}"),
                ),
              ),

              Card(
                color: Colors.blueAccent[100],
                child: ListTile(
                  leading: const Icon(Icons.account_balance_wallet),
                  title: const Text("Balance Disponible"),
                  trailing: Text(
                    "Bs. ${balance.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                "Últimos Movimientos",
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

  Widget _buildMovimientoItem(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final tipo = data["tipo"] ?? "";
    final monto = data["monto"]?.toString() ?? "0";
    final categoria = data["categoria"] ?? "Sin categoría";
    final descripcion = data["descripcion"] ?? "";
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

//////////////////////////////////////////////////////////////////////////////
/// HISTORIAL
//////////////////////////////////////////////////////////////////////////////

class HistorialScreen extends StatelessWidget {
  final String uid;

  const HistorialScreen({super.key, required this.uid});

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
          return const Center(child: Text("No hay movimientos"));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;

            return ListTile(
              title: Text("${data['categoria']} - Bs. ${data['monto']}"),
              subtitle: Text(data['descripcion']),
              trailing: Text(data['tipo']),
            );
          },
        );
      },
    );
  }
}
