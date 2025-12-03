import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/login_screen.dart';
import '../models/user_model.dart';
import 'movimientos/dashboard.dart';
import 'movimientos/registrar_movimiento.dart';
import 'movimientos/historial_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int paginaActual = 0;

  // Navegar a registrar y esperar resultado
  Future<void> _navegarARegistrar() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrarMovimientoScreen(
          uid: widget.user.uid,
          nombre: widget.user.nombre,
        ),
      ),
    );

    // Si se guardó exitosamente, volver al dashboard
    if (resultado == true && mounted) {
      setState(() {
        paginaActual = 0; // Volver al dashboard
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final paginas = [
      Dashboard(uid: widget.user.uid),
      Container(), // Placeholder para registrar
      HistorialScreen(uid: widget.user.uid),
      _buildPerfil(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenido, ${widget.user.nombre}"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (widget.user.rol == "admin")
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Eres administrador")),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: paginaActual,
        children: paginas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: paginaActual,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            // Si toca "Registrar", navegar a la pantalla
            _navegarARegistrar();
          } else {
            setState(() => paginaActual = index);
          }
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
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }

  Widget _buildPerfil() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 80,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              widget.user.nombre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              widget.user.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: widget.user.rol == "admin"
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Rol: ${widget.user.rol}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: widget.user.rol == "admin"
                      ? Colors.orange[800]
                      : Colors.blue[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}