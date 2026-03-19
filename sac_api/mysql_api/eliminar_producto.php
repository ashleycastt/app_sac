<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexion = new mysqli("localhost", "root", "", "sacx24");

if ($conexion->connect_error) {
    echo json_encode(["success" => false, "error" => "Error de conexión"]);
    exit;
}

if (!isset($_POST["id_producto"]) || $_POST["id_producto"] == "") {
    echo json_encode(["success" => false, "error" => "ID_producto no recibido"]);
    exit;
}

$id_producto = $_POST["id_producto"];

// 🔒 Iniciar transacción
$conexion->begin_transaction();

try {
    // 1️⃣ borrar SOLO ese producto en recepciones
    $sql1 = "DELETE FROM recepciones_mercancias WHERE ID_producto = ?";
    $stmt1 = $conexion->prepare($sql1);
    $stmt1->bind_param("s", $id_producto);
    $stmt1->execute();

    // 2️⃣ borrar SOLO ese producto en productos
    $sql2 = "DELETE FROM productos WHERE ID_producto = ?";
    $stmt2 = $conexion->prepare($sql2);
    $stmt2->bind_param("s", $id_producto);
    $stmt2->execute();

    // 🔐 confirmar
    $conexion->commit();

    echo json_encode(["success" => true]);

} catch (Exception $e) {
    $conexion->rollback();
    echo json_encode(["success" => false, "error" => "Error al eliminar"]);
}

$conexion->close();
?>