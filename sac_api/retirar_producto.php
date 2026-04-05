<?php
include 'conexion.php';

$id_lote = $_POST['id_lote'];
$id_empleado = $_POST['id_empleado'];

// actualizar estado
pg_query($conn, "
UPDATE lotes_productos
SET estado = 'retirado'
WHERE id_lote = $id_lote
");

// guardar historial
pg_query($conn, "
INSERT INTO historial_retiros (id_lote, id_empleado)
VALUES ($id_lote, $id_empleado)
");

echo json_encode(["success" => true]);
?>