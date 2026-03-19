<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexion = new mysqli("localhost", "root", "", "sacx24");

if ($conexion->connect_error) {
    echo json_encode(["success" => false, "error" => "Error de conexion"]);
    exit;
}

$sql = "SELECT ID_proveedor, Nombre_empresa FROM Proveedores";
$result = $conexion->query($sql);

$proveedores = [];

while ($row = $result->fetch_assoc()) {
    $proveedores[] = $row;
}

echo json_encode($proveedores);
$conexion->close();
?>