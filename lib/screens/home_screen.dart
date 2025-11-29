import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import 'movimientos/dashboard.dart';
import 'movimientos/registrar_movimiento.dart';
import 'movimientos/historial_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int paginaActual = 0;

  @override
  Widget build(BuildContext context) {
    final paginas = [
      Dashboard(uid: widget.user.uid),                  
      RegistrarMovimientoScreen(uid: widget.user.uid, nombre: widget.user.nombre),
      HistorialScreen(uid: widget.user.uid),
      _buildPerfil(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenido, ${widget.user.nombre}"),
        actions: [
          if (widget.user.rol == "admin")
            IconButton(
              icon: Icon(Icons.admin_panel_settings),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Eres administrador")),
                );
              },
            ),

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),

      body: paginas[paginaActual],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: paginaActual,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => paginaActual = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: "Registrar"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Historial"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }

  Widget _buildPerfil() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 100, color: Colors.deepPurple),
          SizedBox(height: 20),
          Text(
            widget.user.nombre,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            "Rol: ${widget.user.rol}",
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
