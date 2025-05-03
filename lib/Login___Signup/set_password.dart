// file: set_password.dart
// ** Edits marked with // << EDIT **

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart'; // Still using Cloud Functions
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

  // --- Password Validation States ---
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _hasMinLength = false; // << EDIT: Changed requirement to 12
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;
  // --- End Password Validation States ---

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_checkPasswordStrength);
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- Check password strength dynamically ---
  void _checkPasswordStrength() {
    final password = _newPasswordController.text;
    setState(() {
      _hasMinLength = password.length >= 12; // << EDIT: Check for 12 characters
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasDigit = password.contains(RegExp(r'[0-9]'));
      // Using the same symbol set as before for client-side check.
      // Firebase policy covers a broader set: ^ $ * . [ ] { } ( ) ? " ! @ # % & / \ , > < ' : ; | _ ~ etc.
      _hasSpecialChar = password.contains(RegExp(r'[@#$%^&+=!.]')); // << EDIT: Added '.' as an example, adjust as needed or use a broader regex like r'[^\w\s]' for non-alphanumeric
    });
  }
  // --- End Check password strength ---


  // --- Final Password Validation Function ---
  bool _isPasswordValid(String password) {
    // << EDIT: Updated regex to require 12 chars, uppercase, lowercase, digit, and specified symbols
    // Note: Ensure this aligns with your Firebase Policy and the symbols checked in _checkPasswordStrength
    final passwordRegEx = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@#$%^&+=!]).{12,}$');
    return passwordRegEx.hasMatch(password);
  }
  // --- End Final Password Validation Function ---


  // --- Function to call the Cloud Function that resets the password ---
  Future _resetPassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showErrorSnackbar("Please enter and confirm your new password.");
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorSnackbar("Passwords do not match.");
      return;
    }

    // *** Strict client-side validation check ***
    if (!_isPasswordValid(newPassword)) {
      _showErrorSnackbar(
        // << EDIT: Updated error message for 12 characters
        "Password must meet all requirements: min 12 chars, uppercase, lowercase, number, and symbol (@#\$%^&+=!).",
        duration: const Duration(seconds: 4), // Slightly longer duration
      );
      return; // Stop if invalid
    }

    setState(() { _isLoading = true; });

    try {
      // Replace 'resetPasswordWithOtpFunction' with your actual Cloud Function name
      // This assumes you are using a custom OTP flow with Cloud Functions
      final HttpsCallable callable = _functions.httpsCallable('resetPasswordWithOtpFunction');
      final result = await callable.call<Map<String, dynamic>>({
        'email': widget.email, // Use the email passed to this widget
        'newPassword': newPassword,
        // Include OTP/token if your function requires it for final verification
      });

      if (result.data['success'] == true) {
        _showSuccessSnackbar("Password reset successfully. Please sign in.");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
              (Route<dynamic> route) => false, // Remove all previous routes
        );
      } else {
        final errorMessage = result.data['message']?.toString() ?? 'Failed to reset password. Please try again.';
        _showErrorSnackbar(errorMessage);
      }

    } on FirebaseFunctionsException catch (e) {
      print("Cloud Functions Error: ${e.code} - ${e.message}");
      _showErrorSnackbar("Error resetting password: ${e.message ?? 'Please try again.'}");
    } catch (e) {
      print("Generic Error: $e");
      _showErrorSnackbar("An unexpected error occurred. Please try again.");
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }
  // --- End Function to call Cloud Function ---


  // --- Helper for Snackbar ---
  void _showErrorSnackbar(String message, {Duration duration = const Duration(seconds: 3)}) {
    if (!mounted) return; // Check if widget is still in the tree
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red, duration: duration),
    );
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
  // --- End Helper for Snackbar ---


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
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
              Text('Enter a new password for ${widget.email}.', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18), textAlign: TextAlign.center),
              const SizedBox(height: 30),

              // New Password Field
              _buildPasswordField(
                  'New Password',
                  Icons.lock,
                  _newPasswordController,
                  _isPasswordVisible,
                      () => setState(() => _isPasswordVisible = !_isPasswordVisible)
              ),
              const SizedBox(height: 10),

              // Password Requirements Indicators
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // << EDIT: Updated text for length requirement
                    _buildRequirementRow(_hasMinLength, "At least 12 characters"),
                    _buildRequirementRow(_hasUpperCase, "At least one uppercase letter (A-Z)"),
                    _buildRequirementRow(_hasLowerCase, "At least one lowercase letter (a-z)"),
                    _buildRequirementRow(_hasDigit, "At least one number (0-9)"),
                    _buildRequirementRow(_hasSpecialChar, "At least one symbol (@#\$%^&+=!)"), // Match symbol set used in checks
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Confirm Password Field
              _buildPasswordField(
                  'Confirm Password',
                  Icons.lock_outline,
                  _confirmPasswordController,
                  _isConfirmPasswordVisible,
                      () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible)
              ),
              const SizedBox(height: 30),

              // Submit Button
              MaterialButton(
                color: Colors.white,
                elevation: 5.0,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                onPressed: _isLoading ? null : _resetPassword, // Calls the final reset function
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


  // --- Helper Widget for Requirement Rows ---
  Widget _buildRequirementRow(bool isMet, String requirement) {
    final color = isMet ? Colors.green : Colors.red;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(isMet ? Icons.check_circle : Icons.cancel, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(requirement, style: TextStyle(color: color, fontSize: 14)),
          ),
        ],
      ),
    );
  }
  // --- End Helper Widget ---


  // --- Updated TextField Builder for Passwords ---
  Widget _buildPasswordField(
      String hintText,
      IconData icon,
      TextEditingController controller,
      bool isVisible,
      VoidCallback toggleVisibility,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)) ],
      ),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        style: const TextStyle(color: Colors.black),
        // Only add onChanged listener to the *new* password field for strength check
        onChanged: (controller == _newPasswordController) ? (_) => _checkPasswordStrength() : null,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          suffixIcon: IconButton(
            icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
            onPressed: toggleVisibility,
          ),
        ),
      ),
    );
  }
// --- End Updated TextField Builder ---
}
