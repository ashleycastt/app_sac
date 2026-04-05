<?php
include 'conexion.php';

$id_empleado = $_POST['id_empleado'];

$query = "SELECT a.id_area, a.nombre_area
          FROM asignaciones_areas aa
          JOIN areas a ON aa.id_area = a.id_area
          WHERE aa.id_empleado = $1
          AND CURRENT_DATE BETWEEN aa.fecha_inicio AND aa.fecha_fin";

$result = pg_query_params($conn, $query, [$id_empleado]);

if ($row = pg_fetch_assoc($result)) {
    echo json_encode([
        "asignado" => true,
        "id_area" => $row['id_area'],
        "nombre_area" => $row['nombre_area']
    ]);
} else {
    echo json_encode(["asignado" => false]);
}
?>