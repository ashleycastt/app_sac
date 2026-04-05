import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RegistroProductoScreen extends StatefulWidget {
  final int idEmpleado;

  const RegistroProductoScreen({super.key, required this.idEmpleado});

  @override
  State<RegistroProductoScreen> createState() => _RegistroProductoScreenState();
}

class _RegistroProductoScreenState extends State<RegistroProductoScreen> {
  final MobileScannerController controller = MobileScannerController();

  String codigo = "";
  String nombreProducto = "";
  String area = "";
  String proveedor = "";

  bool escaneado = false;

  DateTime? fechaCaducidad;

  int cantidadLote = 0;

  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController codigoManualController = TextEditingController();

  final String baseUrl = "http://192.168.1.63/sac_api/";

  List<Map<String, dynamic>> productosRegistrados = [];

  /// CONFIRMACIÓN DE SALIDA
  Future<bool> mostrarConfirmacionSalida() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirmación"),
            content: const Text("¿Desea salir de este módulo?"),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("Sí"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("No"),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// BUSCAR PRODUCTO
  Future buscarProducto(String codigoBarras) async {
    var response = await http.post(
      Uri.parse("${baseUrl}buscar_producto.php"),
      body: {"codigo_barras": codigoBarras},
    );

    var data = json.decode(response.body);

    if (data["existe"]) {
      setState(() {
        codigo = codigoBarras;
        nombreProducto = data["nombre_producto"];
        area = data["area"] ?? "";
        proveedor = data["proveedor"] ?? "";
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Producto no registrado")));

      resetEscaner();
    }
  }

  /// BUSCAR CODIGO MANUAL
  void buscarCodigoManual() {
    String codigoIngresado = codigoManualController.text.trim();

    if (codigoIngresado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingrese un código de barras")),
      );
      return;
    }

    controller.stop();
    escaneado = true;

    buscarProducto(codigoIngresado);
  }

  /// OBTENER CANTIDAD LOTE
  Future obtenerCantidadLote() async {
    if (codigo.isEmpty || fechaCaducidad == null) return;

    var response = await http.post(
      Uri.parse("${baseUrl}obtener_lote_actual.php"),
      body: {
        "codigo_barras": codigo,
        "fecha_caducidad": fechaCaducidad.toString().substring(0, 10),
      },
    );

    var data = json.decode(response.body);

    setState(() {
      cantidadLote = int.tryParse(data["cantidad"].toString()) ?? 0;
    });
  }

  /// REGISTRAR PRODUCTO
  Future registrarProducto() async {
    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Escanee o ingrese un producto")),
      );
      return;
    }

    if (fechaCaducidad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleccione fecha de caducidad")),
      );
      return;
    }

    /// VALIDACIÓN DE FECHA DE CADUCIDAD (mínimo 31 días)
    DateTime hoy = DateTime.now();
    DateTime fechaMinima = hoy.add(const Duration(days: 30));

    if (fechaCaducidad!.isBefore(fechaMinima)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "La fecha de caducidad debe ser mínimo 31 días mayor a hoy",
          ),
        ),
      );
      return;
    }

    int cantidad = 1;

    if (cantidadController.text.isNotEmpty) {
      cantidad = int.parse(cantidadController.text);
    }

    var response = await http.post(
      Uri.parse("${baseUrl}registrar_lote.php"),
      body: {
        "codigo_barras": codigo,
        "fecha_caducidad": fechaCaducidad.toString().substring(0, 10),
        "cantidad": cantidad.toString(),
        "id_empleado": widget.idEmpleado.toString(),
      },
    );

    var data = json.decode(response.body);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(data["message"])));

    /// GUARDAR PARA PDF
    productosRegistrados.add({
      "nombre": nombreProducto,
      "area": area,
      "proveedor": proveedor,
      "cantidad": cantidad,
      "caducidad": fechaCaducidad.toString().substring(0, 10),
      "registro": DateTime.now().toString().substring(0, 19),
    });

    cantidadController.clear();

    await obtenerCantidadLote();
  }

  /// GENERAR PDF
  Future generarPDF() async {
    final pdf = pw.Document();

    /// AGRUPAR PRODUCTOS
    Map<String, Map<String, dynamic>> agrupados = {};

    for (var p in productosRegistrados) {
      String key = "${p["nombre"]}_${p["caducidad"]}";

      if (agrupados.containsKey(key)) {
        agrupados[key]!["cantidad"] += p["cantidad"];
      } else {
        agrupados[key] = Map<String, dynamic>.from(p);
      }
    }

    List<Map<String, dynamic>> listaFinal = agrupados.values.toList();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Text(
              "Reporte de productos",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 20),

            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(3),
                3: const pw.FlexColumnWidth(3),
                4: const pw.FlexColumnWidth(3),
                5: const pw.FlexColumnWidth(3),
              },
              children: [
                /// ENCABEZADO
                pw.TableRow(
                  children:
                      [
                            "Producto",
                            "Área",
                            "Proveedor",
                            "Cantidad",
                            "Caducidad",
                            "Registro",
                          ]
                          .map(
                            (e) => pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text(
                                e,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),

                /// USAR LISTA AGRUPADA
                ...listaFinal.map((p) {
                  return pw.TableRow(
                    children:
                        [
                              p["nombre"],
                              p["area"],
                              p["proveedor"],
                              p["cantidad"].toString(),
                              p["caducidad"],
                              p["registro"],
                            ]
                            .map(
                              (e) => pw.Padding(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text(e.toString(), softWrap: true),
                              ),
                            )
                            .toList(),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  /// RESET
  void resetEscaner() {
    setState(() {
      codigo = "";
      nombreProducto = "";
      area = "";
      proveedor = "";
      fechaCaducidad = null;
      cantidadController.clear();
      codigoManualController.clear();
      cantidadLote = 0;
      escaneado = false;
    });

    controller.start();
  }

  /// FECHA
  seleccionarFecha() async {
    DateTime? fecha = await showDatePicker(
      context: context,
      // initialDate: DateTime.now(),
      firstDate: DateTime.now().add(const Duration(days: 31)),
      lastDate: DateTime(2100),
    );

    if (fecha != null) {
      setState(() {
        fechaCaducidad = fecha;
      });

      obtenerCantidadLote();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: mostrarConfirmacionSalida,
      child: Scaffold(
        backgroundColor: const Color(0xffF5F7FB),

        appBar: AppBar(
          title: const Text(
            "Registro de productos",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF6E1414),
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        body: SafeArea(
          child: Column(
            children: [
              /// SCANNER
              Container(
                height: 250,
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xffF0B2A8), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: MobileScanner(
                    controller: controller,
                    onDetect: (BarcodeCapture capture) {
                      if (escaneado) return;

                      final barcode = capture.barcodes.first;
                      final String? code = barcode.rawValue;

                      if (code != null) {
                        escaneado = true;
                        controller.stop();
                        buscarProducto(code);
                      }
                    },
                  ),
                ),
              ),

              /// CONTENIDO ORIGINAL COMPLETO (SIN CAMBIOS)
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    children: [
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inventory,
                                size: 50,
                                color: const Color.fromARGB(255, 221, 190, 113),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                nombreProducto.isEmpty
                                    ? "Escanee o ingrese un producto"
                                    : nombreProducto,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 25),

                              TextField(
                                controller: codigoManualController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Código de barras manual",
                                  prefixIcon: const Icon(Icons.qr_code),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              ElevatedButton.icon(
                                icon: const Icon(Icons.search),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    246,
                                    244,
                                    244,
                                  ),
                                ),
                                onPressed: buscarCodigoManual,
                                label: const Text("Buscar producto"),
                              ),

                              const SizedBox(height: 20),

                              ElevatedButton.icon(
                                icon: const Icon(Icons.calendar_today),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    250,
                                    249,
                                    249,
                                  ),
                                ),
                                onPressed: seleccionarFecha,
                                label: Text(
                                  fechaCaducidad == null
                                      ? "Seleccionar fecha de caducidad"
                                      : fechaCaducidad.toString().substring(
                                          0,
                                          10,
                                        ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              TextField(
                                controller: cantidadController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Cantidad (opcional)",
                                  prefixIcon: const Icon(Icons.numbers),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              ElevatedButton.icon(
                                icon: const Icon(Icons.save),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    233,
                                    180,
                                    135,
                                  ),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                onPressed: registrarProducto,
                                label: const Text("Registrar producto"),
                              ),

                              const SizedBox(height: 10),

                              ElevatedButton.icon(
                                icon: const Icon(Icons.picture_as_pdf),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    233,
                                    180,
                                    135,
                                  ),
                                ),
                                onPressed: productosRegistrados.isEmpty
                                    ? null
                                    : generarPDF,
                                label: const Text("Generar PDF"),
                              ),

                              const SizedBox(height: 10),

                              TextButton.icon(
                                onPressed: resetEscaner,
                                icon: const Icon(Icons.qr_code_scanner),
                                label: const Text("Escanear otro producto"),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (nombreProducto.isNotEmpty && fechaCaducidad != null)
                        Card(
                          color: Colors.indigo.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Text(
                                  "Información del lote",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text("Producto: $nombreProducto"),
                                Text(
                                  "Caducidad: ${fechaCaducidad.toString().substring(0, 10)}",
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Cantidad acumulada: $cantidadLote",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
