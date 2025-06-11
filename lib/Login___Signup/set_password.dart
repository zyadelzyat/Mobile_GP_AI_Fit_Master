import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:untitled/Login___Signup/01_signin_screen.dart';
import 'package:untitled/theme_provider.dart';

class SetPasswordScreen extends StatefulWidget {
  final String email;
  const SetPasswordScreen({super.key, required this.email});

  @override
  _SetPasswordScreenState createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Password Validation States
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;

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

  void _checkPasswordStrength() {
    final password = _newPasswordController.text;
    setState(() {
      _hasMinLength = password.length >= 12;
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasDigit = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[@#$%^&+=!.]'));
    });
  }

  bool _isPasswordValid(String password) {
    final passwordRegEx = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@#$%^&+=!]).{12,}$');
    return passwordRegEx.hasMatch(password);
  }

  Future<void> _resetPassword() async {
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

    if (!_isPasswordValid(newPassword)) {
      _showErrorSnackbar(
        "Password must meet all requirements: min 12 chars, uppercase, lowercase, number, and symbol (@#\$%^&+=!).",
        duration: const Duration(seconds: 4),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final HttpsCallable callable = _functions.httpsCallable('resetPasswordWithOtpFunction');
      final result = await callable.call<Map<String, dynamic>>({
        'email': widget.email,
        'newPassword': newPassword,
      });

      if (result.data['success'] == true) {
        _showSuccessSnackbar("Password reset successfully. Please sign in.");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
              (Route<dynamic> route) => false,
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

  void _showErrorSnackbar(String message, {Duration duration = const Duration(seconds: 3)}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: duration,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.appBarTheme.iconTheme?.color ?? Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
              color: theme.appBarTheme.iconTheme?.color ?? Colors.white,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Text(
                'Set New Password',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Enter a new password for ${widget.email}.',
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildPasswordField(
                'New Password',
                Icons.lock,
                _newPasswordController,
                _isPasswordVisible,
                    () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequirementRow(_hasMinLength, "At least 12 characters"),
                    _buildRequirementRow(_hasUpperCase, "At least one uppercase letter (A-Z)"),
                    _buildRequirementRow(_hasLowerCase, "At least one lowercase letter (a-z)"),
                    _buildRequirementRow(_hasDigit, "At least one number (0-9)"),
                    _buildRequirementRow(_hasSpecialChar, "At least one symbol (@#\$%^&+=!)"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                'Confirm Password',
                Icons.lock_outline,
                _confirmPasswordController,
                _isConfirmPasswordVisible,
                    () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              ),
              const SizedBox(height: 30),
              MaterialButton(
                color: theme.brightness == Brightness.light
                    ? Colors.white
                    : theme.colorScheme.primary,
                elevation: 5.0,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                onPressed: _isLoading ? null : _resetPassword,
                child: _isLoading
                    ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(
                      theme.brightness == Brightness.light
                          ? const Color(0xFF232323)
                          : Colors.white,
                    ),
                  ),
                )
                    : Text(
                  'Set Password',
                  style: TextStyle(
                    color: theme.brightness == Brightness.light
                        ? const Color(0xFF232323)
                        : Colors.white,
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

  Widget _buildRequirementRow(bool isMet, String requirement) {
    final theme = Theme.of(context);
    final color = isMet ? Colors.green : theme.colorScheme.error;

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

  Widget _buildPasswordField(
      String hintText,
      IconData icon,
      TextEditingController controller,
      bool isVisible,
      VoidCallback toggleVisibility,
      ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? Colors.white
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        style: TextStyle(
          color: theme.brightness == Brightness.light
              ? Colors.black
              : theme.textTheme.bodyLarge?.color,
        ),
        onChanged: (controller == _newPasswordController) ? (_) => _checkPasswordStrength() : null,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: theme.brightness == Brightness.light
                ? Colors.grey
                : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            icon,
            color: theme.brightness == Brightness.light
                ? Colors.grey
                : theme.iconTheme.color,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: theme.brightness == Brightness.light
                  ? Colors.grey
                  : theme.iconTheme.color,
            ),
            onPressed: toggleVisibility,
          ),
        ),
      ),
    );
  }
}
