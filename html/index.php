<?php
session_start();

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Get form data
    $_SESSION['username'] = $_POST['username'];
    $_SESSION['password'] = $_POST['password'];
    $_SESSION['endpoint'] = $_POST['endpoint'];
    $_SESSION['dbname'] = $_POST['dbname'];
    header("Location: manage.php");
    exit();
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Database Connection</title>
    <style>
        /* CSS styles for index.php */
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
            text-align: center;
        }
        h1 {
            color: #333;
        }
        form {
            margin-top: 50px;
        }
        label {
            display: block;
            margin-bottom: 10px;
        }
        input[type="text"],
        input[type="password"] {
            padding: 8px;
            margin-bottom: 10px;
            width: 200px;
        }
        button[type="submit"] {
            padding: 10px 20px;
            background-color: #007bff;
            color: #fff;
            border: none;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <h1>Database Connection</h1>
    <form action="index.php" method="post">
        <label for="username">Username:</label>
        <input type="text" id="username" name="username" required><br>
        <label for="password">Password:</label>
        <input type="password" id="password" name="password" required><br>
        <label for="endpoint">Database Endpoint:</label>
        <input type="text" id="endpoint" name="endpoint" required><br>
        <label for="dbname">Database Name:</label>
        <input type="text" id="dbname" name="dbname" required><br>
        <button type="submit">Connect to Database</button>
    </form>
</body>
</html>

