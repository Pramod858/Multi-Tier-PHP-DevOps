<?php
session_start();

// If session is not set, redirect to index.php
if (!isset($_SESSION['username'])) {
    header("Location: index.php");
    exit;
}

header("Location: submit-data.php");
exit();
?>

