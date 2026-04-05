<?php
include 'conexion.php';

$id_empleado = $_GET['id_empleado'];

$query = "
SELECT 
    hr.id_retiro,
    hr.id_lote,
    p.nombre_producto,
    l.fecha_caducidad,
    l.cantidad,
    hr.fecha_retiro,
    a.nombre_area,
    aa.fecha_inicio,
    aa.fecha_fin,
    CASE 
        WHEN (l.fecha_caducidad - CURRENT_DATE) <= 2 THEN 'CADUCADO'
        WHEN (l.fecha_caducidad - CURRENT_DATE) < 90 THEN 'PRÓXIMO'
        ELSE 'NORMAL'
    END AS estado
FROM historial_retiros hr
JOIN lotes_productos l ON hr.id_lote = l.id_lote
JOIN productos p ON l.codigo_barras = p.codigo_barras
JOIN areas a ON p.id_area = a.id_area

-- SOLO LA ASIGNACIÓN ACTIVA
JOIN asignaciones_areas aa 
    ON aa.id_area = a.id_area
    AND aa.id_empleado = hr.id_empleado
    AND CURRENT_DATE BETWEEN aa.fecha_inicio AND aa.fecha_fin

WHERE hr.id_empleado = '$id_empleado'

--  SOLO RETIROS DENTRO DEL PERIODO
AND DATE(hr.fecha_retiro) BETWEEN aa.fecha_inicio AND aa.fecha_fin

ORDER BY hr.fecha_retiro DESC
";

$result = pg_query($conn, $query);

$data = [];

while ($row = pg_fetch_assoc($result)) {
    $data[] = $row;
}

echo json_encode($data);
?>