import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<bool> autenticarConHuella() async {
    try {
      bool isSupported = await auth.isDeviceSupported();
      if (!isSupported) return false;

      bool canCheck = await auth.canCheckBiometrics;
      if (!canCheck) return false;

      return await auth.authenticate(
        localizedReason: 'Escanea tu huella para continuar',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> login() async {
    String usuario = usuarioController.text.trim();
    String password = passwordController.text.trim();

    if (usuario.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    bool autorizado = await autenticarConHuella();
    if (!autorizado) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Huella no reconocida")));
      return;
    }

    try {
      var url = Uri.parse("http://192.168.1.63/sac_api/login.php");

      var response = await http.post(
        url,
        body: {"usuario": usuario, "password": password},
      );

      var data = json.decode(response.body);

      if (data["success"] == true) {
        String rol = data["rol"];
        String usuarioDB = data["usuario"];
        int idEmpleado = int.parse(data["id_empleado"].toString());

        String? usuarioGuardado = await storage.read(key: "usuario");
        String? passwordGuardado = await storage.read(key: "password");

        // VALIDACIÓN DE DISPOSITIVO
        if (usuarioGuardado != null && passwordGuardado != null) {
          if (usuario != usuarioGuardado || password != passwordGuardado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Este dispositivo ya está vinculado a otro usuario",
                ),
              ),
            );
            return;
          }
        }

        // Guardar si es primer login
        if (usuarioGuardado == null && passwordGuardado == null) {
          await storage.write(key: "usuario", value: usuario);
          await storage.write(key: "password", value: password);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MenuScreen(
              rol: rol,
              usuario: usuarioDB,
              idEmpleado: idEmpleado,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario o contraseña incorrectos")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A3C),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'SAC',
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: usuarioController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Usuario',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Contraseña',
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: login,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
