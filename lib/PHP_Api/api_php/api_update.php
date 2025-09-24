<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}

$input = getJsonInput();

if (!$input || !isset($input['user_id']) || !isset($input['name']) || !isset($input['email']) || !isset($input['is_active'])) {
    jsonResponse(['success' => false, 'message' => 'Missing required fields']);
}

$userId = intval($input['user_id']);
$name = trim($input['name']);
$email = trim(strtolower($input['email']));
$isActive = intval($input['is_active']);

// Validation
if (empty($name) || empty($email)) {
    jsonResponse(['success' => false, 'message' => 'Name and email are required']);
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    jsonResponse(['success' => false, 'message' => 'Invalid email format']);
}

if ($userId <= 0) {
    jsonResponse(['success' => false, 'message' => 'Invalid user ID']);
}

try {
    // Check if user exists
    $stmt = $pdo->prepare("SELECT id FROM users WHERE id = ?");
    $stmt->execute([$userId]);

    if (!$stmt->fetch()) {
        jsonResponse(['success' => false, 'message' => 'User not found']);
    }

    // Check if email is already taken by another user
    $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ? AND id != ?");
    $stmt->execute([$email, $userId]);

    if ($stmt->fetch()) {
        jsonResponse(['success' => false, 'message' => 'Email is already taken by another user']);
    }

    // Update user
    $stmt = $pdo->prepare("UPDATE users SET name = ?, email = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?");
    $stmt->execute([$name, $email, $isActive, $userId]);

    jsonResponse([
        'success' => true,
        'message' => 'User updated successfully'
    ]);

} catch(PDOException $e) {
    error_log('Update user error: ' . $e->getMessage());
    jsonResponse(['success' => false, 'message' => 'Failed to update user. Please try again.'], 500);
}
?>