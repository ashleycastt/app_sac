<?php
include 'conexion.php';

$usuario = $_POST['usuario'];
$password = $_POST['password'];

$query = "SELECT id_empleado, usuario, rol
          FROM empleados
          WHERE usuario = $1 AND password = $2";

$result = pg_query_params($conn, $query, [$usuario, $password]);

if ($row = pg_fetch_assoc($result)) {

    echo json_encode([
        "success" => true,
        "id_empleado" => $row['id_empleado'],
        "usuario" => $row['usuario'],
        "rol" => $row['rol']
    ]);

} else {

    echo json_encode([
        "success" => false
    ]);

}
?>