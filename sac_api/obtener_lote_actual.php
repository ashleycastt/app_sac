<?php
include 'conexion.php';

$codigo = $_POST['codigo_barras'];
$fecha = $_POST['fecha_caducidad'];

$query = "SELECT cantidad
          FROM lotes_productos
          WHERE codigo_barras = $1
          AND fecha_caducidad = $2
          AND estado='activo'";

$result = pg_query_params($conn, $query, [$codigo, $fecha]);

if ($row = pg_fetch_assoc($result)) {

    echo json_encode([
        "existe" => true,
        "cantidad" => intval($row['cantidad'])
    ]);

} else {

    echo json_encode([
        "existe" => false,
        "cantidad" => 0
    ]);

}
?>