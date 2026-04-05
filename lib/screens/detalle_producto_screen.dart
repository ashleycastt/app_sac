import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetalleProductoScreen extends StatelessWidget {
  final Map producto;
  final int idEmpleado;

  const DetalleProductoScreen({
    super.key,
    required this.producto,
    required this.idEmpleado,
  });

  Future retirar(BuildContext context) async {
    final String baseUrl = "http://192.168.1.63/sac_api/";

    var res = await http.post(
      Uri.parse("${baseUrl}retirar_producto.php"),
      body: {
        "id_lote": producto["id_lote"].toString(),
        "id_empleado": idEmpleado.toString(),
      },
    );

    var data = json.decode(res.body);

    if (data["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Producto marcado como retirado correctamente"),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al retirar el producto")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6E1414),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              producto["nombre_producto"],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text("Caduca: ${producto["fecha_caducidad"]}"),
            Text("Cantidad: ${producto["cantidad"]}"),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 242, 179, 174),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: const Text("Confirmación"),
                      content: const Text(
                        "¿Desea marcar este producto como retirado?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          child: const Text("No"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(
                              dialogContext,
                            ); // cerrar SOLO el diálogo
                            retirar(context); // usar el context ORIGINAL
                          },
                          child: const Text("Sí"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text("Marcar como retirado"),
            ),
          ],
        ),
      ),
    );
  }
}
