import 'package:api_testing/placeholderapis/users_api/login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSONPlaceholder Login App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Primary color scheme
        primarySwatch: Colors.teal,
        useMaterial3: true,

        // App bar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade700),
          hintStyle: TextStyle(color: Colors.grey.shade500),
        ),

        // Card theme
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
        ),

        // Text button theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // Outlined button theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.teal,
            side: const BorderSide(color: Colors.teal),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Snackbar theme
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),

        // Scaffold background color
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),

        // Color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ).copyWith(
          primary: Colors.teal,
          secondary: Colors.teal.shade300,
          surface: Colors.white,
        ),
      ),

      // Set login screen as the home screen
      home: const LoginScreen(),

      // Define routes if you want to add more screens later
      routes: {
        '/login': (context) => const LoginScreen(),
      },

      // Handle initial route
      initialRoute: '/',

      // Global navigation handling
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
          case '/login':
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
              settings: settings,
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
              settings: settings,
            );
        }
      },
    );
  }
}