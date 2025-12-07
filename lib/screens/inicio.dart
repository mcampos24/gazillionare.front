import 'package:flutter/material.dart';
import 'inversiones.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Text(
              'Gazillionare',
              style: TextStyle(
                fontFamily: 'PixelFont',
                fontSize: 48,
                color: Colors.greenAccent,
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 50,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddInversionScreen()),
                );
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
