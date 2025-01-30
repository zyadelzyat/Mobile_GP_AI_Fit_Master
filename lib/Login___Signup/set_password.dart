import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider for state management
import '01_signin_screen.dart'; // Import SignIn screen
import 'package:untitled/theme_provider.dart'; // Import ThemeProvider for theme management

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  _SetPasswordScreenState createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordValid(String password) {
    final passwordRegEx = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@#$%^&+=!]).{6,}$');
    return passwordRegEx.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Access ThemeProvider

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Use theme background color
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
                'Set New Password',
                style: TextStyle(
                  color: Theme.of(context).primaryColor, // Use theme primary color
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Instruction text
              Text(
                'Enter a new password to secure your account.',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color, // Use theme text color
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // New Password input
              _buildTextField('New Password', Icons.lock, _newPasswordController, obscureText: true),
              const SizedBox(height: 20),

              // Confirm Password input
              _buildTextField('Confirm Password', Icons.lock, _confirmPasswordController, obscureText: true),
              const SizedBox(height: 30),

              // Submit Button
              MaterialButton(
                color: Colors.white, // White background for the button
                elevation: 5.0,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                onPressed: () {
                  String newPassword = _newPasswordController.text;
                  String confirmPassword = _confirmPasswordController.text;

                  // Check if the passwords match
                  if (newPassword != confirmPassword) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Passwords do not match."),
                      ),
                    );
                    return;
                  }

                  // Validate password
                  if (!_isPasswordValid(newPassword)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Password must be at least 6 characters, include an uppercase letter, a symbol, and a number."),
                      ),
                    );
                    return;
                  }

                  // Simulate setting the password
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Password has been set successfully."),
                    ),
                  );

                  // Navigate to the Sign In screen after setting the password
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInScreen()),
                  );
                },
                child: const Text(
                  'Set Password',
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

  Widget _buildTextField(String hintText, IconData icon, TextEditingController controller, {bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // White background for text fields
        borderRadius: BorderRadius.circular(15), // Rounded corners (15px radius)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Optional: Add a subtle shadow
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.black), // Black text color for input
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey), // Grey hint text
          prefixIcon: Icon(icon, color: Colors.grey), // Grey icon
          border: InputBorder.none, // Remove default border
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
      ),
    );
  }
}