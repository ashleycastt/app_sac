<?php
include 'conexion.php';

$codigo = $_POST['codigo_barras'];
$fecha = $_POST['fecha_caducidad'];
$id_empleado = $_POST['id_empleado'];

# cantidad enviada desde Flutter
$cantidad = isset($_POST['cantidad']) ? intval($_POST['cantidad']) : 1;

# Buscar si ya existe lote con mismo codigo y fecha

$queryBuscar = "SELECT id_lote, cantidad
                FROM lotes_productos
                WHERE codigo_barras = $1
                AND fecha_caducidad = $2
                AND estado = 'activo'";

$resultBuscar = pg_query_params($conn, $queryBuscar, [$codigo, $fecha]);

if ($row = pg_fetch_assoc($resultBuscar)) {

    # Si existe → sumar cantidad

    $nuevaCantidad = $row['cantidad'] + $cantidad;
    $id_lote = $row['id_lote'];

    $queryUpdate = "UPDATE lotes_productos
                    SET cantidad = $1
                    WHERE id_lote = $2";

    pg_query_params($conn, $queryUpdate, [$nuevaCantidad, $id_lote]);

    echo json_encode([
        "success" => true,
        "message" => "Producto agregado al lote existente"
    ]);

} else {

    # Si no existe → crear lote nuevo

    $queryInsert = "INSERT INTO lotes_productos
                    (codigo_barras, fecha_caducidad, cantidad, id_empleado)
                    VALUES ($1,$2,$3,$4)";

    pg_query_params($conn, $queryInsert, [
        $codigo,
        $fecha,
        $cantidad,
        $id_empleado
    ]);

    echo json_encode([
        "success" => true,
        "message" => "Nuevo lote creado"
    ]);

}
?>