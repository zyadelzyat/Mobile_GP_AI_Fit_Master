import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart'; // Import Cloud Functions
import 'package:untitled/Login___Signup/01_signin_screen.dart'; // Ensure correct path
import 'package:untitled/theme_provider.dart';

class SetPasswordScreen extends StatefulWidget {
  final String email; // Receive email (or token) from OTP verification

  const SetPasswordScreen({super.key, required this.email});

  @override
  _SetPasswordScreenState createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Basic password validation (same as your original)
  bool _isPasswordValid(String password) {
    // Consider making this stronger or aligning with Firebase rules
    final passwordRegEx = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@#$%^&+=!]).{6,}$');
    // Firebase default is 6 characters minimum. Adjust regex if needed.
    // return password.length >= 6; // Simpler check
    return passwordRegEx.hasMatch(password);
  }

  // Function to call the Cloud Function that resets the password
  Future<void> _resetPassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter and confirm your new password."), backgroundColor: Colors.red),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match."), backgroundColor: Colors.red),
      );
      return;
    }

    if (!_isPasswordValid(newPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 6 characters, include an uppercase letter, a symbol, and a number."), // Adjust message based on your _isPasswordValid logic
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // Replace 'resetPasswordWithOtpFunction' with the actual name of your Cloud Function
      final HttpsCallable callable = _functions.httpsCallable('resetPasswordWithOtpFunction');
      // Pass email and new password
      final result = await callable.call<Map<String, dynamic>>({
        'email': widget.email, // Use the email passed to this widget
        'newPassword': newPassword,
      });

      // Check the result from your Cloud Function
      if (result.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password reset successfully. Please sign in."),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to the Sign In screen, clearing the navigation stack
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
              (Route<dynamic> route) => false, // Remove all previous routes
        );
      } else {
        final errorMessage = result.data['message'] ?? 'Failed to reset password. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      print("Cloud Functions Error: ${e.code} - ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error resetting password: ${e.message ?? 'Please try again.'}"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print("Generic Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An unexpected error occurred. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // --- UI remains largely the same as your original code ---
    // --- Key changes are in the onPressed of the 'Set Password' button ---
    // --- Added email property to receive it from EnterCodeScreen ---
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // No AppBar here in your original code, keeping it that way
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              // Optional: Theme Toggle Button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    themeProvider.themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () => themeProvider.toggleTheme(),
                ),
              ),
              Text('Set New Password', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text('Enter a new password for ${widget.email}.', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18), textAlign: TextAlign.center), // Show email for context
              const SizedBox(height: 30),
              _buildTextField('New Password', Icons.lock, _newPasswordController, obscureText: true),
              const SizedBox(height: 20),
              _buildTextField('Confirm Password', Icons.lock_outline, _confirmPasswordController, obscureText: true), // Changed icon
              const SizedBox(height: 30),
              MaterialButton(
                color: Colors.white,
                elevation: 5.0,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                onPressed: _isLoading ? null : _resetPassword, // Call _resetPassword
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF232323))))
                    : const Text('Set Password', style: TextStyle(color: Color(0xFF232323), fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // _buildTextField remains the same
  Widget _buildTextField(String hintText, IconData icon, TextEditingController controller, {bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)) ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          // Optional: Add suffix icon to toggle password visibility
          // suffixIcon: IconButton( ... )
        ),
      ),
    );
  }
}
