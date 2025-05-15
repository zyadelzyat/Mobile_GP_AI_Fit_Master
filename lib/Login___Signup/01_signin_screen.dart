import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'signup_screen.dart';
import 'forgotton_password.dart';
import '../fitness_screen.dart';
import 'package:untitled/theme_provider.dart';
import 'package:untitled/Home__Page/00_home_page.dart';
import 'package:untitled/Admin/admin_dashboard.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (!_isValidEmail(email)) {
      _showSnackBar("Please enter a valid email address.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check user role after successful login
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

          // Check if user is an Admin
          if (userData != null && userData['role'] == 'Admin') {
            // Route to AdminDashboard if user is an admin
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboard(),
              ),
            );
            return;
          }

          // Otherwise handle regular user flow
          bool isProfileComplete = false;
          if (userData != null) {
            isProfileComplete = userData['gender'] != null &&
                userData['height'] != null &&
                userData['weight'] != null &&
                userData['goal'] != null &&
                userData['activityLevel'] != null;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
              isProfileComplete ? const HomePage() : const FitnessScreen(),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Login failed. Please try again.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Google Sign In method
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // If user cancels the sign-in process
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase using the Google credential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Check if user exists in Firestore, if not create a new user document
      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // Create new user document with basic info
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'email': user.email,
            'firstName': user.displayName?.split(' ').first ?? '',
            'lastName': user.displayName?.split(' ').last ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'role': 'Self-Trainee', // Default role for social sign-ins
          });
        }

        // Check user role after successful login
        DocumentSnapshot updatedUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (updatedUserDoc.exists) {
          Map<String, dynamic>? userData = updatedUserDoc.data() as Map<String, dynamic>?;

          // Check if user is an Admin
          if (userData != null && userData['role'] == 'Admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboard(),
              ),
            );
            return;
          }

          // Otherwise handle regular user flow
          bool isProfileComplete = false;
          if (userData != null) {
            isProfileComplete = userData['gender'] != null &&
                userData['height'] != null &&
                userData['weight'] != null &&
                userData['goal'] != null &&
                userData['activityLevel'] != null;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
              isProfileComplete ? const HomePage() : const FitnessScreen(),
            ),
          );
        }
      }
    } catch (e) {
      _showSnackBar("Google Sign In failed: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Facebook Sign In method
  Future<void> _signInWithFacebook() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Check if login was successful
      if (loginResult.status != LoginStatus.success) {
        _showSnackBar("Facebook login canceled or failed");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
      FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      // Sign in with Firebase using the Facebook credential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

      // Check if user exists in Firestore, if not create a new user document
      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // Get additional user info from Facebook
          final userData = await FacebookAuth.instance.getUserData();

          // Create new user document with basic info
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'email': user.email,
            'firstName': userData['name']?.split(' ').first ?? '',
            'lastName': userData['name']?.split(' ').last ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'role': 'Self-Trainee', // Default role for social sign-ins
          });
        }

        // Check user role after successful login
        DocumentSnapshot updatedUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (updatedUserDoc.exists) {
          Map<String, dynamic>? userData = updatedUserDoc.data() as Map<String, dynamic>?;

          // Check if user is an Admin
          if (userData != null && userData['role'] == 'Admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboard(),
              ),
            );
            return;
          }

          // Otherwise handle regular user flow
          bool isProfileComplete = false;
          if (userData != null) {
            isProfileComplete = userData['gender'] != null &&
                userData['height'] != null &&
                userData['weight'] != null &&
                userData['goal'] != null &&
                userData['activityLevel'] != null;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
              isProfileComplete ? const HomePage() : const FitnessScreen(),
            ),
          );
        }
      }
    } catch (e) {
      _showSnackBar("Facebook Sign In failed: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
                    themeProvider.themeMode == ThemeMode.light
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                ),
              ),
              Text(
                'Login',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Welcome!',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFB39DDB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildTextField('Email', Icons.email, _emailController),
                    const SizedBox(height: 20),
                    _buildTextField('Password', Icons.lock, _passwordController, obscureText: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator()
                  : MaterialButton(
                color: Colors.white,
                elevation: 5.0,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                onPressed: _signIn,
                child: const Text(
                  'Log In',
                  style: TextStyle(
                    color: Color(0xFF232323),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Or sign in with',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google Sign In Button
                  _buildSocialButton(
                    onPressed: _signInWithGoogle,
                    icon: 'assets/google_logo.png',
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(width: 20),
                  // Facebook Sign In Button
                  _buildSocialButton(
                    onPressed: _signInWithFacebook,
                    icon: 'assets/facebook_logo.png',
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
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

  Widget _buildTextField(
      String hintText,
      IconData icon,
      TextEditingController controller, {
        bool obscureText = false,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
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
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required String icon,
    required Color backgroundColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        elevation: 2,
      ),
      child: Image.asset(
        icon,
        height: 24,
        width: 24,
      ),
    );
  }
}
