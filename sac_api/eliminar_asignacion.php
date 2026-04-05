<?php
include 'conexion.php';

$id = $_POST['id_asignacion'];

$query = "DELETE FROM asignaciones_areas WHERE id_asignacion = $1";

$result = pg_query_params($conn, $query, [$id]);

echo json_encode(["success" => $result ? true : false]);
?>