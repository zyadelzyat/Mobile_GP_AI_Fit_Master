import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:cloud_functions/cloud_functions.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'set_password.dart';
import 'package:untitled/theme_provider.dart';

class EnterCodeScreen extends StatefulWidget {
  final String email;
  const EnterCodeScreen({super.key, required this.email});

  @override
  _EnterCodeScreenState createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  bool _isValidCode(String code) {
    return code.length == 6 && int.tryParse(code) != null;
  }

  Future<void> _verifyOtp() async {
    final otp = _codeController.text.trim();
    if (!_isValidCode(otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a valid 6-digit code."),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final HttpsCallable callable = _functions.httpsCallable('verifyOtpFunction');
      final result = await callable.call<Map<String, dynamic>>({
        'email': widget.email,
        'otp': otp,
      });

      if (result.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("OTP verified successfully."),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SetPasswordScreen(email: widget.email),
          ),
        );
      } else {
        final errorMessage = result.data['message']?.toString() ?? 'Invalid or expired OTP.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      print("Cloud Functions Error: ${e.code} - ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error verifying OTP: ${e.message ?? 'Please try again.'}"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (e) {
      print("Generic Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("An unexpected error occurred. Please try again."),
          backgroundColor: Theme.of(context).colorScheme.error,
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
              themeProvider.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
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
                'Enter the 6-digit Code',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Check your email (${widget.email}) for the 6-digit code.',
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildTextField('Enter Code', Icons.lock_open, _codeController),
              const SizedBox(height: 30),
              MaterialButton(
                color: theme.brightness == Brightness.light
                    ? Colors.white
                    : theme.colorScheme.primary,
                elevation: 5.0,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                onPressed: _isLoading ? null : _verifyOtp,
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
                  'Verify Code',
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

  Widget _buildTextField(String hintText, IconData icon, TextEditingController controller) {
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
        keyboardType: TextInputType.number,
        maxLength: 6,
        style: TextStyle(
          color: theme.brightness == Brightness.light
              ? Colors.black
              : theme.textTheme.bodyLarge?.color,
          letterSpacing: 5.0,
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: hintText,
          counterText: "",
          hintStyle: TextStyle(
            color: theme.brightness == Brightness.light
                ? Colors.grey
                : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            letterSpacing: 0,
          ),
          prefixIcon: Icon(
            icon,
            color: theme.brightness == Brightness.light
                ? Colors.grey
                : theme.iconTheme.color,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
      ),
    );
  }
}
