import 'package:flutter/material.dart';
import 'set_password.dart'; // استيراد صفحة SetPasswordScreen

class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({super.key});

  @override
  _EnterCodeScreenState createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final TextEditingController _codeController = TextEditingController();

  bool _isValidCode(String code) {
    // هنا يمكن التحقق من الكود، في الوقت الحالي سيتم قبول أي كود مكون من 6 أرقام.
    return code.length == 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 50),

              // Title
              const Text(
                'Enter the 6-digit Code',
                style: TextStyle(
                  color: Color(0xFFE2F163), // Lime color for 'Enter Code' text
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Instruction text
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

              // Code input
              _buildTextField('Enter Code', Icons.lock, _codeController),
              const SizedBox(height: 30),

              // Verify Code Button
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

                  // التحقق من صحة الكود
                  if (!_isValidCode(code)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a valid 6-digit code."),
                      ),
                    );
                    return;
                  }

                  // إذا كان الكود صحيحاً، انتقل إلى صفحة Set Password
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SetPasswordScreen()),
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
