<?php
include 'conexion.php';

$codigo = $_POST['codigo_barras'];

$query = "SELECT 
            p.nombre_producto,
            a.nombre_area,
            pr.nombre_proveedor
          FROM productos p
          LEFT JOIN areas a ON p.id_area = a.id_area
          LEFT JOIN proveedores pr ON p.id_proveedor = pr.id_proveedor
          WHERE p.codigo_barras = $1";

$result = pg_query_params($conn, $query, [$codigo]);

if ($row = pg_fetch_assoc($result)) {

    echo json_encode([
        "existe" => true,
        "nombre_producto" => $row['nombre_producto'],
        "area" => $row['nombre_area'],           
        "proveedor" => $row['nombre_proveedor']  
    ]);

} else {

    echo json_encode([
        "existe" => false
    ]);

}
?>