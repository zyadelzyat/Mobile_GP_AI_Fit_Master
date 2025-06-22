import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/Login___Signup/forgotton_password.dart';

class PasswordSettingsPage extends StatefulWidget {
  const PasswordSettingsPage({super.key});

  @override
  State<PasswordSettingsPage> createState() => _PasswordSettingsPageState();
}

class _PasswordSettingsPageState extends State<PasswordSettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers للتحكم في النص
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Variables لإظهار/إخفاء كلمات المرور
  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  // Variable للتحكم في حالة التحميل
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // دالة للتحقق من كلمة المرور الحالية
  Future<bool> _verifyCurrentPassword(String currentPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        // إنشاء credential بالإيميل وكلمة المرور الحالية
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        // محاولة إعادة المصادقة
        await user.reauthenticateWithCredential(credential);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // دالة تغيير كلمة المرور
  Future<void> _changePassword() async {
    // التحقق من أن جميع الحقول مملوءة
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showErrorSnackBar('Please fill all fields');
      return;
    }

    // التحقق من أن كلمة المرور الجديدة والتأكيد متطابقان
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('New passwords do not match');
      return;
    }

    // التحقق من قوة كلمة المرور الجديدة
    if (_newPasswordController.text.length < 6) {
      _showErrorSnackBar('New password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // التحقق من كلمة المرور الحالية
      bool isCurrentPasswordValid = await _verifyCurrentPassword(_currentPasswordController.text);

      if (!isCurrentPasswordValid) {
        _showErrorSnackBar('Current password is incorrect');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // تغيير كلمة المرور
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(_newPasswordController.text);

        // مسح الحقول بعد النجاح
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        _showSuccessSnackBar('Password changed successfully');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please log in again before changing password';
          break;
        default:
          errorMessage = 'Failed to change password: ${e.message}';
      }
      _showErrorSnackBar(errorMessage);
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // دالة لإظهار رسالة خطأ
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // دالة لإظهار رسالة نجاح
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.yellow),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Password Settings',
          style: TextStyle(
            color: Color(0xFF896CFE),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text("Current Password", style: TextStyle(color: Color(0xFF896CFE), fontSize: 16)),
            const SizedBox(height: 8),
            buildPasswordField(
                controller: _currentPasswordController,
                isVisible: showCurrentPassword,
                onVisibilityToggle: (val) {
                  setState(() => showCurrentPassword = val);
                }
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Color(0xFF896CFE),
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text("New Password", style: TextStyle(color: Color(0xFF896CFE), fontSize: 16)),
            const SizedBox(height: 8),
            buildPasswordField(
                controller: _newPasswordController,
                isVisible: showNewPassword,
                onVisibilityToggle: (val) {
                  setState(() => showNewPassword = val);
                }
            ),
            const SizedBox(height: 24),
            const Text("Confirm New Password", style: TextStyle(color: Color(0xFF896CFE), fontSize: 16)),
            const SizedBox(height: 8),
            buildPasswordField(
                controller: _confirmPasswordController,
                isVisible: showConfirmPassword,
                onVisibilityToggle: (val) {
                  setState(() => showConfirmPassword = val);
                }
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE2F163),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
                    : const Text("Change Password"),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFB19CD9),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Support'),
        ],
      ),
    );
  }

  Widget buildPasswordField({
    required TextEditingController controller,
    required bool isVisible,
    required Function(bool) onVisibilityToggle
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFF896CFE),
          ),
          onPressed: () => onVisibilityToggle(!isVisible),
        ),
      ),
    );
  }
}