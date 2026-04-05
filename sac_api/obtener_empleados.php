<?php
include 'conexion.php';

$query = "SELECT id_empleado, usuario FROM empleados";
$result = pg_query($conn, $query);

$empleados = [];

while ($row = pg_fetch_assoc($result)) {
    $empleados[] = $row;
}

echo json_encode($empleados);
?>