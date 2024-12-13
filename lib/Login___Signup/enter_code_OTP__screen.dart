import 'package:flutter/material.dart';
import 'set_password.dart'; // Import SetPasswordScreen

class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({super.key});

  @override
  _EnterCodeScreenState createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final TextEditingController _codeController = TextEditingController();

  bool _isValidCode(String code) {
    return code.length == 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      appBar: AppBar(
        backgroundColor: const Color(0xFF232323), // Same as background color
        elevation: 0, // Remove AppBar shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Back icon
          onPressed: () {
            Navigator.pop(context); // Go back to ResetPasswordScreen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 50),
              const Text(
                'Enter the 6-digit Code',
                style: TextStyle(
                  color: Color(0xFFE2F163),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Check your email for the 6-digit code.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildTextField('Enter Code', Icons.lock, _codeController),
              const SizedBox(height: 30),
              MaterialButton(
                color: Colors.white,
                elevation: 5.0,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                onPressed: () {
                  String code = _codeController.text;

                  if (!_isValidCode(code)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a valid 6-digit code."),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SetPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Verify Code',
                  style: TextStyle(
                    color: Color(0xFF232323),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              MaterialButton(
                color: Colors.grey[700],
                elevation: 2.0,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                onPressed: () {
                  Navigator.pop(context); // Go back to ResetPasswordScreen
                },
                child: const Text(
                  'Back to Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, IconData icon, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
