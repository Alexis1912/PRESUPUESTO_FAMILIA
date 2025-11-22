import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key}); // <- Asegúrate de NO usar const aquí

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _paginaActual = 0;

  final List<Widget> _paginas = [
    Center(child: Text("📊 Resumen General")),
    Center(child: Text("💰 Registrar Movimiento")),
    Center(child: Text("📁 Historial de Gastos")),
    Center(child: Text("⚙ Configuración")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Presupuesto Familiar"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),

      body: _paginas[_paginaActual],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaActual,
        onTap: (index) {
          setState(() {
            _paginaActual = index;
          });
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey[700], // 🔹 Mejor visibilidad
        backgroundColor: Colors.white, // 🔹 Barra más contrastada
        type: BottomNavigationBarType.fixed,
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
