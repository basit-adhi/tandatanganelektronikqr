<?php
// ini_set('display_errors', 1);
// ini_set('display_startup_errors', 1);
// error_reporting(E_ALL);
include_once "db.php";
include_once "config.php";
?>
<head>
<title>Tanda Tangan Digital dan Elektronik - <?=$org_?></title>
<style>a:link,a:visited,a:active {color:<?=$color_["link"]?>} a:hover {color:<?=$color_["hover"]?>}</style>
</head>
<?php
echo '<body cz-shortcut-listen="true" style="font-family: Palatino;padding: 100px;font-size: 1.5em;background:'.$color_["background"].';color: '.$color_["text"].';">';
$conn = new mysqli("localhost", $dbuser_, $dbpass_, $dbname_);
$conn->init();
$conn->real_connect("localhost",$dbuser_, $dbpass_, $dbname_, 3306);
if ($conn->connect_error)
{
   die('CONNERR');
}
$r   = $_SERVER['REQUEST_URI'];
$req = explode("/", $r);
$stmt = $conn->prepare("call select_tte(?, ?)");
$stmt->bind_param("ss", $req[2], $pepper_);
$stmt->execute();
$result = $stmt->get_result();
if ($result->num_rows === 0)
{
   echo json_encode(['status' => 'error', 'message' => 'Tanda tangan digital (ttd) tidak ditemukan.']);
}
else
{
 while ($row = $result->fetch_assoc())
 {
     echo json_encode(['status' => 'success', 'message' => $row["tandatanganelektronikqr"]],  JSON_UNESCAPED_SLASHES);
 }
}
$stmt->close();
?>
</body>