<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexion = new mysqli("localhost", "root", "", "sacx24");
if ($conexion->connect_error) {
    echo json_encode(["success" => false, "error" => "Error de conexión"]);
    exit;
}

$old_id = $_POST["id_producto_old"];
$nombre = $_POST["nombre"];
$area = $_POST["area"];
$proveedor = $_POST["proveedor"];
$cantidad = intval($_POST["cantidad"]);
$fecha_vencimiento = $_POST["fecha_vencimiento"];

if ($old_id == "" || $nombre == "" || $cantidad <= 0 || $fecha_vencimiento == "") {
    echo json_encode(["success" => false, "error" => "Datos inválidos"]);
    exit;
}

$letras = strtoupper(substr($nombre, 0, 3));
$resultado = $conexion->query("SELECT COUNT(*) AS total FROM productos");
$fila = $resultado->fetch_assoc();
$consecutivo = $fila["total"];
$new_id = $consecutivo . $letras;

$conexion->begin_transaction();

try {
    // 1️⃣ actualizar productos
    $sql = "UPDATE productos 
            SET ID_producto = ?, Nombre = ?, Area = ?, ID_proveedor = ?, 
                Cantidad_recibida = ?, Fecha_vencimiento = ?, Fecha_registro = NOW()
            WHERE ID_producto = ?";

    $stmt = $conexion->prepare($sql);
    $stmt->bind_param("ssssiss", $new_id, $nombre, $area, $proveedor, $cantidad, $fecha_vencimiento, $old_id);
    $stmt->execute();

    // 2️⃣ actualizar recepciones
    $sql2 = "UPDATE recepciones_mercancias 
             SET ID_producto = ?
             WHERE ID_producto = ?";

    $stmt2 = $conexion->prepare($sql2);
    $stmt2->bind_param("ss", $new_id, $old_id);
    $stmt2->execute();

    $conexion->commit();

    echo json_encode([
        "success" => true,
        "new_id" => $new_id
    ]);

} catch (Exception $e) {
    $conexion->rollback();
    echo json_encode(["success" => false, "error" => "Error al actualizar"]);
}

$conexion->close();
?>