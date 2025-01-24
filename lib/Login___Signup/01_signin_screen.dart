import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider for state management
import 'signup_screen.dart'; // Import SignUp screen
import 'forgotton_password.dart'; // Import ResetPasswordScreen
import '../fitness_screen.dart'; // Import FitnessScreen
import 'package:untitled/theme_provider.dart'; // Import ThemeProvider for theme management

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
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
                'Login',
                style: TextStyle(
                  color: Theme.of(context).primaryColor, // Use theme primary color
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Welcome text
              Text(
                'Welcome!',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color, // Use theme text color
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // Purple Background behind Text Fields
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFB39DDB), // Light purple background color
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
                child: Column(
                  children: [
                    // Email input with validation
                    _buildTextField('Email', Icons.email, _emailController),
                    const SizedBox(height: 20),

                    // Password input
                    _buildTextField('Password', Icons.lock, _passwordController, obscureText: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Forgot password
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color, // Use theme text color
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Log In Button
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

                  // Navigate to FitnessScreen after validation
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FitnessScreen()),
                  );
                },
                child: Text(
                  'Log In',
                  style: TextStyle(
                    color: Color(0xFF232323), // Black text for the button
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Don't have an account prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don’t have an account? ',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color, // Use theme text color
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to SignUp screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor, // Use theme primary color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.black), // Black text color for input
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey), // Grey hint text
          prefixIcon: Icon(icon, color: Colors.grey), // Grey icon
          border: InputBorder.none, // Remove default border
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
      ),
    );
  }
}