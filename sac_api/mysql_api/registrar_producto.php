<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conexion = new mysqli("localhost", "root", "", "sacx24");

if ($conexion->connect_error) {
    echo json_encode(["success" => false, "error" => "Error de conexion"]);
    exit;
}

$nombre = $_POST["nombre"];
$area = $_POST["area"];
$proveedor = $_POST["proveedor"];
$cantidad = intval($_POST["cantidad"]);
$fecha_vencimiento = $_POST["fecha_vencimiento"];
$id_empleado = $_POST["id_empleado"];

// ================= VALIDACIONES =================

if ($nombre == "" || $fecha_vencimiento == "") {
    echo json_encode(["success" => false, "error" => "Campos vacios"]);
    exit;
}

if ($cantidad <= 0) {
    echo json_encode(["success" => false, "error" => "Cantidad invalida"]);
    exit;
}

// Validar fecha (mínimo 10 días después de hoy)
$limite = date("Y-m-d", strtotime("+10 days"));

if ($fecha_vencimiento < $limite) {
    echo json_encode(["success" => false, "error" => "Fecha invalida"]);
    exit;
}

// ================= GENERAR ID_PRODUCTO =================

$resultado = $conexion->query("SELECT COUNT(*) AS total FROM Productos");
$fila = $resultado->fetch_assoc();
$consecutivo = $fila["total"] + 1;

$letras = strtoupper(substr($nombre, 0, 3));
$id_producto = $consecutivo . $letras;

// ================= INSERT PRODUCTO =================

$sql = "INSERT INTO Productos 
(ID_producto, Nombre, Area, ID_proveedor, Cantidad_recibida, Fecha_vencimiento, ID_empleado_responsable, Fecha_registro)
VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";

$stmt = $conexion->prepare($sql);
$stmt->bind_param("ssssiss", $id_producto, $nombre, $area, $proveedor, $cantidad, $fecha_vencimiento, $id_empleado);

if ($stmt->execute()) {

    // ================= INSERT RECEPCION =================
    $id_recepcion = "RECEP" . $id_producto;

    $sql2 = "INSERT INTO recepciones_mercancias (ID_recepcion, ID_producto)
             VALUES (?, ?)";

    $stmt2 = $conexion->prepare($sql2);
    $stmt2->bind_param("ss", $id_recepcion, $id_producto);
    $stmt2->execute();

    echo json_encode([
        "success" => true,
        "id_producto" => $id_producto,
        "id_recepcion" => $id_recepcion
    ]);

} else {
    echo json_encode([
        "success" => false,
        "error" => $stmt->error
    ]);
}

$conexion->close();
?>