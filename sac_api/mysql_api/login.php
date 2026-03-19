<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'conexion.php';

$usuario = $_POST['usuario'] ?? '';
$password = $_POST['password'] ?? '';

if ($usuario == "" || $password == "") {
    echo json_encode(["success" => false, "error" => "Campos vacios"]);
    exit;
}

$sql = "SELECT ID_empleado, Cargo 
        FROM empleados 
        WHERE ID_empleado = ? AND Contraseña = ?";

$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $usuario, $password);
$stmt->execute();
$resultado = $stmt->get_result();

if ($resultado->num_rows > 0) {
    $fila = $resultado->fetch_assoc();

    echo json_encode([
        "success" => true,
        "cargo" => $fila["Cargo"],
        "id_empleado" => $fila["ID_empleado"]
    ]);
} else {
    echo json_encode(["success" => false]);
}

$conn->close();
?>