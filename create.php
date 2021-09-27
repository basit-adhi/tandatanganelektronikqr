<?php
// ini_set('display_errors', 1);
// ini_set('display_startup_errors', 1);
// error_reporting(E_ALL);
include_once "db.php";
include_once "config.php";
header('Content-Type: application/json');
header('Cache-Control: no-store');

$pass       = filter_input(INPUT_POST, "ps", FILTER_SANITIZE_STRING);
$text       = filter_input(INPUT_POST, "tx", FILTER_SANITIZE_STRING);
$cheksum    = filter_input(INPUT_POST, "cs", FILTER_SANITIZE_STRING);

if (password_verify($pass, $pass_))
{
    $conn = new mysqli("localhost", $dbuser_, $dbpass_, $dbname_);
    $conn->init();
    $conn->real_connect("localhost",$dbuser_, $dbpass_, $dbname_, 3306);
    if ($conn->connect_error)
    {
       die('CONNERR');
    }
    $r   = $_SERVER['REQUEST_URI'];
    $req = explode("/", $r);
    $stmt       = $conn->prepare("call insert_tte(?, ?, ?)");
    $stmt->bind_param("sss", $pepper_, $text, $cheksum);
    $stmt->execute();
    $result = $stmt->get_result();
    if ($result->num_rows === 0)
    {
       echo json_encode(['status' => 'error', 'message' => 'Tanda tangan digital (ttd) gagal, mohon dapat diulangi beberapa saat lagi.']);
    }
    else
    {
     while ($row = $result->fetch_assoc())
     {
        $stmt->close();
        $u = $url_."check/";
        $stmt    = $conn->prepare("select url_tte(?, ?) as urlqr");
        $stmt->bind_param("si", $u, $row["kdtandatanganelektronikqr"]);
        $stmt->execute();
        $resulturl = $stmt->get_result();
        if ($resulturl->num_rows === 0)
        {
          echo json_encode(['status' => 'error', 'message' => 'Tanda tangan digital (ttd) gagal, mohon dapat diulangi beberapa saat lagi.']);
        }
        else
        {
         while ($rowurl = $resulturl->fetch_assoc())
         {
            echo json_encode(['status' => 'success', 'message' => $rowurl["urlqr"]],  JSON_UNESCAPED_SLASHES);
            break;
         }
        }
        break;
     }
    }
    $stmt->close();
}
else
{
    echo json_encode(['status' => 'error', 'message' => 'Password tidak valid.']);
}
