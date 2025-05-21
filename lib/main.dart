import 'package:flutter/material.dart';
import 'package:pibble/UI/login.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';  // Import your provider file

void main() {
  runApp(
    // Wrap the app with the ChangeNotifierProvider to make UserProvider available globally
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(), // Replace with your actual initial page
    );
  }
}
