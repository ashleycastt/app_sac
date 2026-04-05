<?php
include 'conexion.php';

$query = "SELECT id_area, nombre_area FROM areas";
$result = pg_query($conn, $query);

$areas = [];

while ($row = pg_fetch_assoc($result)) {
    $areas[] = $row;
}

echo json_encode($areas);
?>