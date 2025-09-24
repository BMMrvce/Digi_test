import 'package:flutter/material.dart';
import 'qc_vation_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QCVationScreen()),
          );
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // RISE Above Logo
                Image.asset(
                  'assets/rise.png', // Replace with your asset path
                  height: 180,
                ),
                const SizedBox(height: 100),
                const Text(
                  'WELCOME\nto the\nWORLD of',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,

                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 0,
                  ),
                ),
                const SizedBox(height: 24.0),
                // Paramount Logo
                const SizedBox(height: 60),
                Image.asset(
                  'assets/paramount_logo.png', // Replace with your asset path
                  height: 100,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}