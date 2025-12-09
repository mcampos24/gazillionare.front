import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // ← Asegúrate de importar tu HomeScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gazillionare',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(), // ← ¡Aquí va tu pantalla principal!
    );
  }
}