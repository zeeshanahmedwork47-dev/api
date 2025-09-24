<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);

if (!$input || !isset($input['email']) || !isset($input['password'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Email and password are required']);
    exit;
}

$email = trim($input['email']);
$password = $input['password'];

if (empty($email) || empty($password)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Email and password cannot be empty']);
    exit;
}

try {
    // Check if this is admin login
    if ($email === 'admin@admin.com') {
        // Check admin credentials
        $stmt = $pdo->prepare("SELECT id, name, email, password FROM admins WHERE email = ?");
        $stmt->execute([$email]);
        $admin = $stmt->fetch();

        if (!$admin) {
            http_response_code(401);
            echo json_encode(['success' => false, 'message' => 'Invalid credentials']);
            exit;
        }

        // Check password - handle both hashed and plain text passwords
        $passwordValid = false;

        if (password_verify($password, $admin['password'])) {
            $passwordValid = true;
        } else if ($password === $admin['password']) {
            $passwordValid = true;
            // Hash the password for future use
            $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
            $updateStmt = $pdo->prepare("UPDATE admins SET password = ? WHERE id = ?");
            $updateStmt->execute([$hashedPassword, $admin['id']]);
        }

        if ($passwordValid) {
            // Admin login successful
            echo json_encode([
                'success' => true,
                'message' => 'Admin login successful',
                'user_type' => 'admin',
                'user' => [
                    'id' => $admin['id'],
                    'name' => $admin['name'],
                    'email' => $admin['email'],
                    'type' => 'admin'
                ]
            ]);
            exit;
        } else {
            http_response_code(401);
            echo json_encode(['success' => false, 'message' => 'Invalid admin credentials']);
            exit;
        }
    }

    // Regular user login
    $stmt = $pdo->prepare("SELECT id, email, password, name FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if (!$user) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Invalid credentials',
            'debug' => 'User not found' // Remove this in production
        ]);
        exit;
    }

    // Debug: Check what's in the database
    error_log("User found: " . print_r($user, true));
    error_log("Password from input: " . $password);
    error_log("Password from DB: " . $user['password']);

    // Verify password
    if (password_verify($password, $user['password'])) {
        // User login successful
        echo json_encode([
            'success' => true,
            'message' => 'Login successful',
            'user_type' => 'user',
            'user' => [
                'id' => $user['id'],
                'email' => $user['email'],
                'name' => $user['name'],
                'type' => 'user'
            ]
        ]);
    } else {
        // For debugging - check if it's plain text password
        if ($password === $user['password']) {
            // Plain text password match - hash it and login
            $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
            $updateStmt = $pdo->prepare("UPDATE users SET password = ? WHERE id = ?");
            $updateStmt->execute([$hashedPassword, $user['id']]);

            echo json_encode([
                'success' => true,
                'message' => 'Login successful',
                'user_type' => 'user',
                'user' => [
                    'id' => $user['id'],
                    'email' => $user['email'],
                    'name' => $user['name'],
                    'type' => 'user'
                ]
            ]);
        } else {
            http_response_code(401);
            echo json_encode([
                'success' => false,
                'message' => 'Invalid credentials',
                'debug' => 'Password verification failed' // Remove this in production
            ]);
        }
    }
} catch(PDOException $e) {
    error_log('Login error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}
?>