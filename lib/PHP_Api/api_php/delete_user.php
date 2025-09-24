<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}

$input = getJsonInput();

if (!$input || !isset($input['user_id'])) {
    jsonResponse(['success' => false, 'message' => 'User ID is required']);
}

$userId = intval($input['user_id']);

if ($userId <= 0) {
    jsonResponse(['success' => false, 'message' => 'Invalid user ID']);
}

try {
    // Check if user exists
    $stmt = $pdo->prepare("SELECT id, name FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();

    if (!$user) {
        jsonResponse(['success' => false, 'message' => 'User not found']);
    }

    // Delete user
    $stmt = $pdo->prepare("DELETE FROM users WHERE id = ?");
    $stmt->execute([$userId]);

    if ($stmt->rowCount() > 0) {
        jsonResponse([
            'success' => true,
            'message' => 'User deleted successfully'
        ]);
    } else {
        jsonResponse(['success' => false, 'message' => 'Failed to delete user']);
    }

} catch(PDOException $e) {
    error_log('Delete user error: ' . $e->getMessage());
    jsonResponse(['success' => false, 'message' => 'Failed to delete user. Please try again.'], 500);
}
?>