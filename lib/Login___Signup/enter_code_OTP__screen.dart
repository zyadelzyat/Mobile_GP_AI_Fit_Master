import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider for state management
import 'set_password.dart'; // Import SetPasswordScreen
import 'package:untitled/theme_provider.dart'; // Import ThemeProvider for theme management

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
    final themeProvider = Provider.of<ThemeProvider>(context); // Access ThemeProvider

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Use theme background color
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // Use theme app bar color
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

              // Theme Toggle Button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    themeProvider.themeMode == ThemeMode.light
                        ? Icons.dark_mode // Dark mode icon
                        : Icons.light_mode, // Light mode icon
                    color: Theme.of(context).iconTheme.color, // Use theme icon color
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme(); // Toggle between light and dark mode
                  },
                ),
              ),

              // Title
              Text(
                'Enter the 6-digit Code',
                style: TextStyle(
                  color: Theme.of(context).primaryColor, // Use theme primary color
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Instruction text
              Text(
                'Check your email for the 6-digit code.',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color, // Use theme text color
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Code input field
              _buildTextField('Enter Code', Icons.lock, _codeController),
              const SizedBox(height: 30),

              // Verify Code Button
              MaterialButton(
                color: Colors.white, // White background for the button
                elevation: 5.0,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
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
                    color: Color(0xFF232323), // Black text for the button
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Back to Email Button
              MaterialButton(
                color: Colors.grey[700], // Grey background for the button
                elevation: 2.0,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                onPressed: () {
                  Navigator.pop(context); // Go back to ResetPasswordScreen
                },
                child: const Text(
                  'Back to Email',
                  style: TextStyle(
                    color: Colors.white, // White text for the button
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