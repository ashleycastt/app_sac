<?php
header('Content-Type: application/json');
include 'conexion.php';

// VALIDAR DATOS
if (
    !isset($_POST['id_empleado']) ||
    !isset($_POST['id_area']) ||
    !isset($_POST['fecha_inicio']) ||
    !isset($_POST['fecha_fin'])
) {
    echo json_encode([
        "success" => false,
        "message" => "Faltan datos"
    ]);
    exit;
}

$id_empleado = $_POST['id_empleado'];
$id_area = $_POST['id_area'];
$fecha_inicio = $_POST['fecha_inicio'];
$fecha_fin = $_POST['fecha_fin'];

// VALIDAR DUPLICADO EXACTO
$queryDuplicado = "
SELECT 1 FROM asignaciones_areas
WHERE id_empleado = $1
AND id_area = $2
AND fecha_inicio = $3
AND fecha_fin = $4
";

$resultDuplicado = pg_query_params($conn, $queryDuplicado, [
    $id_empleado,
    $id_area,
    $fecha_inicio,
    $fecha_fin
]);

if (pg_num_rows($resultDuplicado) > 0) {
    echo json_encode([
        "success" => false,
        "message" => "Esta asignación ya existe (mismo empleado, área y fechas)"
    ]);
    exit;
}

// VALIDAR SOLAPAMIENTO DEL ÁREA 
$queryArea = "
SELECT 1 FROM asignaciones_areas
WHERE id_area = $1
AND (
    (fecha_inicio BETWEEN $2 AND $3) OR
    (fecha_fin BETWEEN $2 AND $3) OR
    ($2 BETWEEN fecha_inicio AND fecha_fin)
)
";

$resultArea = pg_query_params($conn, $queryArea, [
    $id_area,
    $fecha_inicio,
    $fecha_fin
]);

if (pg_num_rows($resultArea) > 0) {
    echo json_encode([
        "success" => false,
        "message" => "Esta área ya está asignada a otro empleado en ese rango de fechas"
    ]);
    exit;
}


// INSERTAR
$query = "
INSERT INTO asignaciones_areas (id_empleado, id_area, fecha_inicio, fecha_fin)
VALUES ($1, $2, $3, $4)
";

$result = pg_query_params($conn, $query, [
    $id_empleado,
    $id_area,
    $fecha_inicio,
    $fecha_fin
]);

if ($result) {
    echo json_encode([
        "success" => true,
        "message" => "Asignación guardada correctamente"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Error al guardar"
    ]);
}
?>