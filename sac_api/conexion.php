<?php
$host = "localhost";
$port = "5432";
$dbname = "sac";
$user = "postgres";
$password = "olaya11";

$conn = pg_connect("host=$host port=$port dbname=$dbname user=$user password=$password");

if (!$conn) {
    echo json_encode(["error" => "No se pudo conectar"]);
}
?>