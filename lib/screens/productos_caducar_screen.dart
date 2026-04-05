import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'detalle_producto_screen.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class ProductosCaducarScreen extends StatefulWidget {
  final int idEmpleado;

  const ProductosCaducarScreen({super.key, required this.idEmpleado});

  @override
  State<ProductosCaducarScreen> createState() => _ProductosCaducarScreenState();
}

class _ProductosCaducarScreenState extends State<ProductosCaducarScreen> {
  final String baseUrl = "http://192.168.1.63/sac_api/";

  List productos = [];
  List productosRetirados = [];

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  Future cargarProductos() async {
    var res = await http.get(
      Uri.parse(
        "${baseUrl}obtener_productos_area.php?id_empleado=${widget.idEmpleado}",
      ),
    );

    var data = json.decode(res.body);

    setState(() {
      productos = data;
    });
  }

  Future generarPDF() async {
    try {
      //  CONSULTA AL PHP
      final res = await http.get(
        Uri.parse(
          "${baseUrl}obtener_historial_retiros.php?id_empleado=${widget.idEmpleado}",
        ),
      );

      final data = json.decode(res.body);

      //  VALIDACIÓN
      if (data.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No has retirado productos")),
        );
        return;
      }

      final pdf = pw.Document();
      final font = await PdfGoogleFonts.notoSansRegular();
      final bold = await PdfGoogleFonts.notoSansBold();

      String area = (data[0]["nombre_area"] ?? "").toString();
      String fechaInicio = (data[0]["fecha_inicio"] ?? "").toString();
      String fechaFin = (data[0]["fecha_fin"] ?? "").toString();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (context) => [
            //  TÍTULO
            pw.Center(
              child: pw.Text(
                "CONTROL DE CADUCIDADES POR PERSONA",
                style: pw.TextStyle(font: bold, fontSize: 18),
              ),
            ),

            pw.SizedBox(height: 15),

            //  INFO
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "ID del empleado: ${widget.idEmpleado}",
                    style: pw.TextStyle(font: font),
                  ),
                  pw.Text(
                    "Área revisada: $area",
                    style: pw.TextStyle(font: font),
                  ),
                  pw.Text(
                    "Periodo asignado: $fechaInicio - $fechaFin",
                    style: pw.TextStyle(font: font),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            //  TABLA COMPLETA
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FlexColumnWidth(2),
                5: const pw.FlexColumnWidth(2),
              },
              children: [
                //  HEADER
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children:
                      [
                            "Lote",
                            "Producto",
                            "Caducidad",
                            "Cantidad",
                            "Estado",
                            "Fecha de retiro",
                          ]
                          .map(
                            (text) => pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                text,
                                style: pw.TextStyle(font: bold, fontSize: 10),
                              ),
                            ),
                          )
                          .toList(),
                ),

                //  DATOS
                ...data.map<pw.TableRow>((e) {
                  final estado = (e["estado"] ?? "").toString();

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: getColorEstadoPDF(estado),
                    ),
                    children:
                        [
                              (e["id_lote"] ?? "").toString(),
                              (e["nombre_producto"] ?? "").toString(),
                              (e["fecha_caducidad"] ?? "").toString(),
                              (e["cantidad"] ?? "").toString(),
                              (e["estado"] ?? "").toString(),
                              (e["fecha_retiro"] ?? "").toString(),
                            ]
                            .map(
                              (text) => pw.Padding(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  text,
                                  style: pw.TextStyle(font: font, fontSize: 9),
                                ),
                              ),
                            )
                            .toList(),
                  );
                }).toList(),
              ],
            ),

            pw.SizedBox(height: 80),

            //  FIRMAS
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                pw.Column(
                  children: [
                    pw.Container(width: 200, child: pw.Divider()),
                    pw.Text(
                      "Firma del líder de tienda",
                      style: pw.TextStyle(font: font),
                    ),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Container(width: 200, child: pw.Divider()),
                    pw.Text(
                      "Firma del asesor",
                      style: pw.TextStyle(font: font),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

      //  PREVISUALIZACIÓN
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      print("ERROR PDF:");
      print(e);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  int diasRestantes(String fecha) {
    return DateTime.parse(fecha).difference(DateTime.now()).inDays;
  }

  Color getColor(int dias) {
    if (dias <= 2) return Colors.red;
    if (dias < 90) return Colors.orange;
    return Colors.green;
  }

  String getEstado(int dias) {
    if (dias <= 2) return "CADUCADO";
    if (dias < 90) return "PRÓXIMO";
    return "NORMAL";
  }

  PdfColor getColorEstadoPDF(String estado) {
    if (estado == "CADUCADO") {
      return PdfColors.red100; // rojo clarito
    } else if (estado == "PRÓXIMO") {
      return PdfColors.orange100; // naranja clarito
    }
    return PdfColors.white; // normal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lotes por caducar",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6E1414),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              generarPDF();
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F7FB),

      body: productos.isEmpty
          ? const Center(
              child: Text(
                "No hay productos disponibles",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: productos.length,
              itemBuilder: (context, index) {
                var p = productos[index];
                int dias = diasRestantes(p["fecha_caducidad"]);

                return GestureDetector(
                  onTap: () async {
                    int dias = diasRestantes(p["fecha_caducidad"]);

                    if (dias >= 90) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Este producto aún está en estado NORMAL",
                          ),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      return;
                    }

                    final resultado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetalleProductoScreen(
                          producto: p,
                          idEmpleado: widget.idEmpleado,
                        ),
                      ),
                    );

                    if (resultado != null && resultado == true) {
                      setState(() {
                        productosRetirados.add(p);
                      });
                    }

                    cargarProductos();
                  },
                  child: Card(
                    elevation: 5,
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: getColor(dias), width: 6),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        title: Text(
                          p["nombre_producto"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Caduca: ${p["fecha_caducidad"]}\nCantidad: ${p["cantidad"]}",
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dias == 1 ? "1 día" : "$dias días",
                              style: TextStyle(
                                color: getColor(dias),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(getEstado(dias)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
