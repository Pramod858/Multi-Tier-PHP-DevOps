<?php
session_start();

// Get form data
$_SESSION['username'] = $_POST['username'];
$_SESSION['password'] = $_POST['password'];
$_SESSION['endpoint'] = $_POST['endpoint'];
$_SESSION['dbname'] = $_POST['dbname'];

header("Location: submit-data.php");
exit();
?>
