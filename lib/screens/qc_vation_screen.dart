import 'package:flutter/material.dart';
import 'login_screen.dart';

class QCVationScreen extends StatefulWidget {
  const QCVationScreen({super.key});

  @override
  State<QCVationScreen> createState() => _QCVationScreenState();
}

class _QCVationScreenState extends State<QCVationScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the LoginScreen after a 3-second delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Robotic and Human Hand Image (assuming this is part of the QCVation screen)

              Image.asset(
                'assets/qclogo.png',
                // Replace with your asset path
                height: 80,
              ),
              const SizedBox(height: 8.0),
              Image.asset(
                'assets/humanrobo.png',
                // Replace with your asset path
                height: 200,
              ),
              const SizedBox(height: 16.0),
              // QCVation Logo and Slogan


              const SizedBox(height: 40.0),
              // Paramount Logo
              Image.asset(
                'assets/paramount_logo.png',
                // Replace with your asset path
                height: 80,
              ),
            ],
          ),
        ),
      ),
    );
  }
}