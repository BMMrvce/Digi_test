import 'package:flutter/material.dart';
import 'login_screen.dart'; // <-- Import your LoginScreen

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoginHovered = false; // <-- State variable for hover effect

  // Submit function
  void _signUp() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account Created Successfully")),
      );
    }
  }

  // Reusable TextField widget
  Widget _textField(String label, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: (value) =>
        value == null || value.isEmpty ? "Enter $label" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 50),
              Image.asset(
                "assets/humanrobo.png",
                height: 100,
              ),
              Image.asset(
                'assets/qcvation.png',
                height: 80,
              ),
              const SizedBox(height: 16),
              const Text(
                "CREATE AN ACCOUNT",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // All input fields
              _textField("First Name"),
              _textField("Middle Name"),
              _textField("Last Name"),
              _textField("Mobile"),
              _textField("Email"),
              _textField("Password", obscure: true),
              _textField("Confirm Password", obscure: true),
              _textField("Company Name"),
              _textField("Designation"),
              _textField("Address"),
              _textField("City"),
              _textField("State"),
              _textField("Country"),
              _textField("Tax ID / GST No."),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Create Account"),
              ),

              const SizedBox(height: 16),
              // Corrected: Text with blue color and hover effect
              MouseRegion(
                onEnter: (_) => setState(() => _isLoginHovered = true),
                onExit: (_) => setState(() => _isLoginHovered = false),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    "Already a user? Log in",
                    style: TextStyle(
                      color: _isLoginHovered ? Colors.blue.shade800 : Colors.blue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}