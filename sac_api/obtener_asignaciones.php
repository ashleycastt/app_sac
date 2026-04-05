<?php
include 'conexion.php';

$where = [];

if (isset($_GET['id_empleado']) && $_GET['id_empleado'] != "") {
    $where[] = "aa.id_empleado = '" . $_GET['id_empleado'] . "'";
}

if (isset($_GET['id_area']) && $_GET['id_area'] != "") {
    $where[] = "aa.id_area = '" . $_GET['id_area'] . "'";
}

if (isset($_GET['fecha']) && $_GET['fecha'] != "") {
    $where[] = "aa.fecha_inicio = '" . $_GET['fecha'] . "'";
}

$sqlWhere = "";
if (count($where) > 0) {
    $sqlWhere = "WHERE " . implode(" AND ", $where);
}

$query = "SELECT aa.id_asignacion, e.usuario, a.nombre_area,
                 aa.fecha_inicio, aa.fecha_fin
          FROM asignaciones_areas aa
          JOIN empleados e ON aa.id_empleado = e.id_empleado
          JOIN areas a ON aa.id_area = a.id_area
          $sqlWhere
          ORDER BY aa.fecha_inicio ASC";

$result = pg_query($conn, $query);

$datos = [];

while ($row = pg_fetch_assoc($result)) {
    $datos[] = $row;
}

echo json_encode($datos);
?>