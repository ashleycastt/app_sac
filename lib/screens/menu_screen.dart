import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'registro_producto_screen.dart';

class MenuScreen extends StatelessWidget {
  final String rol;
  final String usuario;
  final int idEmpleado;

  const MenuScreen({
    super.key,
    required this.rol,
    required this.usuario,
    required this.idEmpleado,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E1414),
        elevation: 4,
        centerTitle: true,
        title: Text(
          "Menú - $rol",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(6),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB22222),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (rol == "lider" || rol == "encargado")
              menuButton(Icons.add_box, "Registro de productos", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RegistroProductoScreen(idEmpleado: idEmpleado),
                  ),
                );
              }),

            menuButton(Icons.inventory, "Asignación de áreas", () {}),

            menuButton(Icons.warning, "Productos por caducar", () {}),

            if (rol == "lider")
              menuButton(
                Icons.supervisor_account,
                "Gestión de usuarios",
                () {},
              ),
          ],
        ),
      ),
    );
  }

  Widget menuButton(IconData icon, String text, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD2691E),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
