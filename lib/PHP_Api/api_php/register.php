<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}

$input = getJsonInput();

if (!$input || !isset($input['name']) || !isset($input['email']) || !isset($input['password'])) {
    jsonResponse(['success' => false, 'message' => 'Missing required fields']);
}

$name = trim($input['name']);
$email = trim(strtolower($input['email']));
$password = $input['password'];

// Validation
if (empty($name) || empty($email) || empty($password)) {
    jsonResponse(['success' => false, 'message' => 'All fields are required']);
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    jsonResponse(['success' => false, 'message' => 'Invalid email format']);
}

if (strlen($name) < 2) {
    jsonResponse(['success' => false, 'message' => 'Name must be at least 2 characters long']);
}

if (strlen($password) < 64) { // SHA256 hash is 64 characters
    jsonResponse(['success' => false, 'message' => 'Invalid password format']);
}

try {
    // Check if email already exists
    $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);

    if ($stmt->fetch()) {
        jsonResponse(['success' => false, 'message' => 'Email is already registered']);
    }

    // Insert new user
    $stmt = $pdo->prepare("INSERT INTO users (name, email, password) VALUES (?, ?, ?)");
    $stmt->execute([$name, $email, $password]);

    jsonResponse([
        'success' => true,
        'message' => 'User registered successfully',
        'user_id' => $pdo->lastInsertId()
    ]);

} catch(PDOException $e) {
    error_log('Registration error: ' . $e->getMessage());
    jsonResponse(['success' => false, 'message' => 'Registration failed. Please try again.'], 500);
}
?>