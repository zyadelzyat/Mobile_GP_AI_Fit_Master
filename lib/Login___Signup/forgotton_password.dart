import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider for state management
import 'enter_code_OTP__screen.dart'; // Import EnterCodeScreen
import 'package:untitled/theme_provider.dart'; // Import ThemeProvider for theme management

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Access ThemeProvider

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Use theme background color
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // Use theme app bar color
        elevation: 0, // Remove AppBar shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Back icon
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
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
              Text(
                'Reset Password',
                style: TextStyle(
                  color: Theme.of(context).primaryColor, // Use theme primary color
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Enter your email to receive a 6-digit reset code.',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color, // Use theme text color
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildTextField('Email', Icons.email, _emailController),
              const SizedBox(height: 30),
              MaterialButton(
                color: Colors.white, // White background for the button
                elevation: 5.0,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                onPressed: () {
                  String email = _emailController.text;
                  if (!_isValidEmail(email)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a valid email address."),
                      ),
                    );
                    return;
                  }

                  // Simulate sending a code and navigate to EnterCodeScreen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("6-digit code has been sent to your email."),
                    ),
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EnterCodeScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Send Code',
                  style: TextStyle(
                    color: Color(0xFF232323), // Black text for the button
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
        color: Colors.white, // White background for text fields
        borderRadius: BorderRadius.circular(15), // Rounded corners (15px radius)
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.black), // Black text color for input
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey), // Grey hint text
          prefixIcon: Icon(icon, color: Colors.grey), // Grey icon
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
      ),
    );
  }
}