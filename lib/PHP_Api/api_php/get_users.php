<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}

try {
    // Get all users (excluding passwords)
    $stmt = $pdo->prepare("SELECT id, name, email, is_active, created_at, updated_at FROM users ORDER BY created_at DESC");
    $stmt->execute();
    $users = $stmt->fetchAll();

    jsonResponse([
        'success' => true,
        'users' => $users,
        'total' => count($users)
    ]);

} catch(PDOException $e) {
    error_log('Get users error: ' . $e->getMessage());
    jsonResponse(['success' => false, 'message' => 'Failed to fetch users. Please try again.'], 500);
}
?>