<?php
session_start();

// Check if logout button is clicked
if(isset($_POST['logout'])) {
    // Destroy the session
    session_destroy();
    // Redirect to index.html
    header("Location: index.html");
    exit;
}

// If session is not set, redirect to index.html
if (!isset($_SESSION['username'])) {
    header("Location: index.html");
    exit;
}

# // Get database connection parameters from session
# $servername = $_SESSION['endpoint'];
# $username = $_SESSION['username'];
# $password = $_SESSION['password'];
# $dbname = $_SESSION['dbname'];

// Get database connection parameters from environment variables or session
$servername = getenv('DB_HOST') ?: $_SESSION['endpoint'];
$username = getenv('DB_USER') ?: $_SESSION['username'];
$password = getenv('DB_PASSWORD') ?: $_SESSION['password'];
$dbname = getenv('DB_NAME') ?: $_SESSION['dbname'];



// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} else {
    echo "Connected to database successfully!<br>";
}

// SQL query to check if the table exists
$table_check_sql = "SHOW TABLES LIKE 'employee'";
$table_result = $conn->query($table_check_sql);

// If the table does not exist, create it
if ($table_result->num_rows == 0) {
    $create_table_sql = "CREATE TABLE employee (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(30) NOT NULL,
        number INT(6) NOT NULL
    )";

    if ($conn->query($create_table_sql) === TRUE) {
        echo "Employee table created successfully!<br>";
    } else {
        echo "Error creating table: " . $conn->error . "<br>";
    }
}

// Handle form submission for adding new data
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['name']) && isset($_POST['number'])) {
    // Get form data
    $name = $_POST['name'];
    $number = $_POST['number'];

    // SQL query to insert data into table
    $insert_sql = "INSERT INTO employee (name, number) VALUES ('$name', '$number')";

    if ($conn->query($insert_sql) === TRUE) {
        echo "New record created successfully<br>";
    } else {
        echo "Error: " . $insert_sql . "<br>" . $conn->error;
    }
}

// Handle record deletion
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['delete_id'])) {
    // Get ID of record to delete
    $id = $_POST['delete_id'];

    // SQL query to delete record
    $delete_sql = "DELETE FROM employee WHERE id = '$id'";

    if ($conn->query($delete_sql) === TRUE) {
        echo "Record deleted successfully<br>";
    } else {
        echo "Error deleting record: " . $conn->error;
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Add Data to Table</title>
    <style>
        /* CSS styles for submit-data.php */
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
        table {
            margin: 50px auto;
            border-collapse: collapse;
            width: 80%;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #007bff;
            color: #fff;
        }
        form {
            margin-bottom: 20px;
            margin-top: 20px;
        }
        label {
            display: block;
            margin-bottom: 10px;
        }
        button[type="submit"] {
            padding: 5px 10px;
            background-color: #dc3545;
            color: #fff;
            border: none;
            cursor: pointer;
        }
        input[type="text"],
        input[type="number"] {
            padding: 8px;
            margin-bottom: 10px;
            width: 200px;
        }
        a {
            text-decoration: none;
            color: #007bff;
        }
    </style>
</head>
<body>
    <h1>Add Data to Table</h1>
    <form action="submit-data.php" method="post">
        <label for="name">Name:</label>
        <input type="text" id="name" name="name" required><br>
        <label for="number">Number:</label>
        <input type="number" id="number" name="number" required><br>
        <button type="submit">Add Data</button>
    </form>

    <table>
        <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Number</th>
            <th>Action</th>
        </tr>
        <?php
        // Display added data
        $select_sql = "SELECT * FROM employee";
        $result = $conn->query($select_sql);

        if ($result->num_rows > 0) {
            while($row = $result->fetch_assoc()) {
                echo "<tr><td>" . $row["id"] . "</td><td>" . $row["name"] . "</td><td>" . $row["number"] . "</td><td><form method='post'><input type='hidden' name='delete_id' value='" . $row["id"] . "'><button type='submit'>Delete</button></form></td></tr>";
            }
        } else {
            echo "<tr><td colspan='4'>No records found</td></tr>";
        }
        ?>
    </table>

    <form action="" method="post">
        <button type="submit" name="logout">Logout</button>
    </form>
</body>
</html>

<?php
$conn->close();
?>

