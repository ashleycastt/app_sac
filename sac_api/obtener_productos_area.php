<?php
include 'conexion.php';

$id_empleado = $_GET['id_empleado'];

$query = "
SELECT 
    l.id_lote,
    p.nombre_producto,
    l.fecha_caducidad,
    l.cantidad,
    a.nombre_area,
    l.estado
FROM lotes_productos l
JOIN productos p ON l.codigo_barras = p.codigo_barras
JOIN areas a ON p.id_area = a.id_area
JOIN asignaciones_areas aa ON aa.id_area = a.id_area
WHERE aa.id_empleado = '$id_empleado'
AND CURRENT_DATE BETWEEN aa.fecha_inicio AND aa.fecha_fin
AND l.estado != 'retirado'
ORDER BY l.fecha_caducidad ASC
";

$result = pg_query($conn, $query);

$data = [];

while ($row = pg_fetch_assoc($result)) {
    $data[] = $row;
}

echo json_encode($data);
?>