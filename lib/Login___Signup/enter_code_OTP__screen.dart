// file: enter_code_OTP__screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart'; // Import Cloud Functions
import 'set_password.dart';
import 'package:untitled/theme_provider.dart';

class EnterCodeScreen extends StatefulWidget {
  final String email; // Receive email from the previous screen
  const EnterCodeScreen({super.key, required this.email});

  @override
  _EnterCodeScreenState createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  bool _isValidCode(String code) {
    // Basic validation: 6 digits
    return code.length == 6 && int.tryParse(code) != null;
  }

  // Function to call the Cloud Function that verifies the OTP
  Future<void> _verifyOtp() async {
    final otp = _codeController.text.trim();
    if (!_isValidCode(otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 6-digit code."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // Replace 'verifyOtpFunction' with the actual name of your Cloud Function
      final HttpsCallable callable = _functions.httpsCallable('verifyOtpFunction');
      // Pass both email and OTP to the function
      final result = await callable.call<Map<String, dynamic>>({
        'email': widget.email, // Use the email passed to this widget
        'otp': otp,
      });

      // Check the result from your Cloud Function
      if (result.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP verified successfully."),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to set password screen, passing the email
        Navigator.pushReplacement( // Use pushReplacement to prevent going back
          context,
          MaterialPageRoute(
            builder: (context) => SetPasswordScreen(email: widget.email), // Pass email
          ),
        );
      } else {
        final errorMessage = result.data['message']?.toString() ?? 'Invalid or expired OTP.';
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
          content: Text("Error verifying OTP: ${e.message ?? 'Please try again.'}"),
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: Colors.white,
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
              Text('Enter the 6-digit Code', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text('Check your email (${widget.email}) for the 6-digit code.', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18), textAlign: TextAlign.center),
              const SizedBox(height: 30),
              _buildTextField('Enter Code', Icons.lock_open, _codeController),
              const SizedBox(height: 30),
              MaterialButton(
                color: Colors.white,
                elevation: 5.0,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                onPressed: _isLoading ? null : _verifyOtp, // Calls the OTP verification function
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(Color(0xFF232323))))
                    : const Text('Verify Code', style: TextStyle(color: Color(0xFF232323), fontSize: 18, fontWeight: FontWeight.bold)),
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
        borderRadius: BorderRadius.circular(15),
        boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)) ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        maxLength: 6,
        style: const TextStyle(color: Colors.black, letterSpacing: 5.0),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: hintText,
          counterText: "",
          hintStyle: const TextStyle(color: Colors.grey, letterSpacing: 0),
          // Using a generic icon, maybe change to something like pin or numbers
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
      ),
    );
  }
}
