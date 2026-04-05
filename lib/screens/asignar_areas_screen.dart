import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AsignarAreasScreen extends StatefulWidget {
  const AsignarAreasScreen({super.key});

  @override
  State<AsignarAreasScreen> createState() => _AsignarAreasScreenState();
}

class _AsignarAreasScreenState extends State<AsignarAreasScreen> {
  final String baseUrl = "http://192.168.1.63/sac_api/";

  List empleados = [];
  List areas = [];
  List asignaciones = [];

  int? empleadoSeleccionado;
  int? areaSeleccionada;

  // FILTROS
  int? filtroEmpleado;
  int? filtroArea;
  DateTime? filtroFecha;

  DateTime? fechaInicio;
  DateTime? fechaFin;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future cargarDatos({int? empleado, int? area, String? fecha}) async {
    var emp = await http.get(Uri.parse("${baseUrl}obtener_empleados.php"));
    var ar = await http.get(Uri.parse("${baseUrl}obtener_areas.php"));

    String url = "${baseUrl}obtener_asignaciones.php?";

    if (empleado != null) url += "id_empleado=$empleado&";
    if (area != null) url += "id_area=$area&";
    if (fecha != null) url += "fecha=$fecha&";

    var asig = await http.get(Uri.parse(url));

    var empleadosData = json.decode(emp.body);
    var areasData = json.decode(ar.body);
    var asignacionesData = json.decode(asig.body);

    setState(() {
      empleados = empleadosData;
      areas = areasData;

      asignaciones = asignacionesData
          .map(
            (e) => {
              "id_asignacion": int.parse(e["id_asignacion"].toString()),
              "usuario": e["usuario"],
              "nombre_area": e["nombre_area"],
              "fecha_inicio": e["fecha_inicio"],
              "fecha_fin": e["fecha_fin"],
            },
          )
          .toList();
    });
  }

  Future guardarAsignacion() async {
    if (empleadoSeleccionado == null ||
        areaSeleccionada == null ||
        fechaInicio == null ||
        fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete todos los campos")),
      );
      return;
    }

    if (fechaFin!.isBefore(fechaInicio!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La fecha fin no puede ser menor")),
      );
      return;
    }

    var response = await http.post(
      Uri.parse("${baseUrl}asignar_area.php"),
      body: {
        "id_empleado": empleadoSeleccionado.toString(),
        "id_area": areaSeleccionada.toString(),
        "fecha_inicio": fechaInicio.toString().substring(0, 10),
        "fecha_fin": fechaFin.toString().substring(0, 10),
      },
    );

    var data = json.decode(response.body);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(data["message"] ?? "Guardado")));

    cargarDatos();
  }

  Future eliminar(int id) async {
    await http.post(
      Uri.parse("${baseUrl}eliminar_asignacion.php"),
      body: {"id_asignacion": id.toString()},
    );

    cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final ultimoDiaAnio = DateTime(hoy.year, 12, 31);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text(
          "Asignación de áreas",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6E1414),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            /// FORMULARIO (INTACTO)
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    DropdownButtonFormField(
                      hint: const Text("Empleado"),
                      items: empleados.map<DropdownMenuItem>((e) {
                        return DropdownMenuItem(
                          value: int.parse(e["id_empleado"].toString()),
                          child: Text(e["usuario"]),
                        );
                      }).toList(),
                      onChanged: (value) => empleadoSeleccionado = value,
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField(
                      hint: const Text("Área"),
                      items: areas.map<DropdownMenuItem>((a) {
                        return DropdownMenuItem(
                          value: int.parse(a["id_area"].toString()),
                          child: Text(a["nombre_area"]),
                        );
                      }).toList(),
                      onChanged: (value) => areaSeleccionada = value,
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              fechaInicio = await showDatePicker(
                                context: context,
                                initialDate: hoy,
                                firstDate: hoy,
                                lastDate: ultimoDiaAnio,
                              );
                              setState(() {});
                            },
                            child: Text(
                              fechaInicio == null
                                  ? "Inicio"
                                  : fechaInicio.toString().substring(0, 10),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              fechaFin = await showDatePicker(
                                context: context,
                                initialDate: fechaInicio ?? hoy,
                                firstDate: fechaInicio ?? hoy,
                                lastDate: ultimoDiaAnio,
                              );
                              setState(() {});
                            },
                            child: Text(
                              fechaFin == null
                                  ? "Fin"
                                  : fechaFin.toString().substring(0, 10),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// BOTÓN VERDE ORIGINAL
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          222,
                          235,
                          138,
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: guardarAsignacion,
                      child: const Text("Guardar asignación"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// FILTROS
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Filtros",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField(
                      hint: const Text("Filtrar por empleado"),
                      value: filtroEmpleado,
                      items: empleados.map<DropdownMenuItem>((e) {
                        return DropdownMenuItem(
                          value: int.parse(e["id_empleado"].toString()),
                          child: Text(e["usuario"]),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => filtroEmpleado = value),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField(
                      hint: const Text("Filtrar por área"),
                      value: filtroArea,
                      items: areas.map<DropdownMenuItem>((a) {
                        return DropdownMenuItem(
                          value: int.parse(a["id_area"].toString()),
                          child: Text(a["nombre_area"]),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => filtroArea = value),
                    ),

                    const SizedBox(height: 10),

                    /// FILTRO POR FECHA
                    ElevatedButton(
                      onPressed: () async {
                        filtroFecha = await showDatePicker(
                          context: context,
                          initialDate: hoy,
                          firstDate: DateTime(2024),
                          lastDate: ultimoDiaAnio,
                        );
                        setState(() {});
                      },
                      child: Text(
                        filtroFecha == null
                            ? "Filtrar por fecha"
                            : filtroFecha.toString().substring(0, 10),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                222,
                                235,
                                138,
                              ),
                            ),
                            onPressed: () {
                              cargarDatos(
                                empleado: filtroEmpleado,
                                area: filtroArea,
                                fecha: filtroFecha?.toString().substring(0, 10),
                              );
                            },
                            child: const Text("Filtrar"),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                222,
                                235,
                                138,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                filtroEmpleado = null;
                                filtroArea = null;
                                filtroFecha = null;
                              });
                              cargarDatos();
                            },
                            child: const Text("Limpiar"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// TABLA
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Asignaciones guardadas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: asignaciones.length,
              itemBuilder: (context, index) {
                var a = asignaciones[index];

                return Card(
                  child: ListTile(
                    title: Text("${a["usuario"]} → ${a["nombre_area"]}"),
                    subtitle: Text("${a["fecha_inicio"]} - ${a["fecha_fin"]}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          eliminar(int.parse(a["id_asignacion"].toString())),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
