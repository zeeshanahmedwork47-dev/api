<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}

$input = getJsonInput();

if (!$input || !isset($input['email']) || !isset($input['password'])) {
    jsonResponse(['success' => false, 'message' => 'Email and password are required']);
}

$email = trim(strtolower($input['email']));
$password = $input['password'];

// Validation
if (empty($email) || empty($password)) {
    jsonResponse(['success' => false, 'message' => 'Email and password are required']);
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    jsonResponse(['success' => false, 'message' => 'Invalid email format']);
}

try {
    // Find admin by email and password
    $stmt = $pdo->prepare("SELECT * FROM admins WHERE email = ? AND password = ?");
    $stmt->execute([$email, $password]);
    $admin = $stmt->fetch();

    if (!$admin) {
        jsonResponse(['success' => false, 'message' => 'Invalid admin credentials']);
    }

    // Remove password from response
    unset($admin['password']);

    jsonResponse([
        'success' => true,
        'message' => 'Admin login successful',
        'admin' => $admin
    ]);

} catch(PDOException $e) {
    error_log('Admin login error: ' . $e->getMessage());
    jsonResponse(['success' => false, 'message' => 'Admin login failed. Please try again.'], 500);
}
?>