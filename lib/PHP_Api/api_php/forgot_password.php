<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}

$input = getJsonInput();

if (!$input || !isset($input['email'])) {
    jsonResponse(['success' => false, 'message' => 'Email is required'], 400);
}

$email = trim(strtolower($input['email']));

// Validation
if (empty($email)) {
    jsonResponse(['success' => false, 'message' => 'Email is required'], 400);
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    jsonResponse(['success' => false, 'message' => 'Invalid email format'], 400);
}

try {
    // Check if user exists
    $stmt = $pdo->prepare("SELECT id, name, email FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if (!$user) {
        // Don't reveal if email exists or not for security
        jsonResponse([
            'success' => true,
            'message' => 'If this email exists in our system, you will receive a password reset link shortly.'
        ]);
    }

    // Generate reset token
    $token = bin2hex(random_bytes(32));
    $expires_at = date('Y-m-d H:i:s', strtotime('+1 hour'));

    // Check if password_resets table exists, create if not
    $pdo->exec("CREATE TABLE IF NOT EXISTS password_resets (
        id INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(255) NOT NULL,
        token VARCHAR(255) NOT NULL,
        expires_at DATETIME NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        used TINYINT(1) DEFAULT 0
    )");

    // Delete existing reset tokens for this email
    $stmt = $pdo->prepare("DELETE FROM password_resets WHERE email = ?");
    $stmt->execute([$email]);

    // Insert new reset token
    $stmt = $pdo->prepare("INSERT INTO password_resets (email, token, expires_at) VALUES (?, ?, ?)");
    $stmt->execute([$email, $token, $expires_at]);

    // Send reset email
    $emailSent = sendResetEmail($email, $token);

    if ($emailSent) {
        jsonResponse([
            'success' => true,
            'message' => 'Password reset instructions have been sent to your email address.',
            // For debugging only - remove in production:
            'debug_info' => [
                'token' => $token,
                'expires_at' => $expires_at,
                'reset_link' => "http://yourapp.com/reset-password?token=$token"
            ]
        ]);
    } else {
        jsonResponse([
            'success' => false,
            'message' => 'Failed to send reset email. Please try again later.'
        ], 500);
    }

} catch(PDOException $e) {
    error_log('Forgot password error: ' . $e->getMessage());
    jsonResponse([
        'success' => false,
        'message' => 'Failed to process password reset. Please try again later.'
    ], 500);
}
?>