import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '01_signin_screen.dart';
import 'package:intl/intl.dart';
import 'package:untitled/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart'; // Add this package
import 'dart:async';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _otherDiseaseController = TextEditingController();

  String? _selectedRole;
  String? _selectedCoach;
  String? _selectedDisease;
  final List<String> _diseases = ['No Diseases', 'Heart Diseases', 'Diabetes', 'Blood Pressure', 'Other'];
  bool _isLoading = false;
  bool _loadingTrainers = false;
  bool _isVerifyingEmail = false;
  List<Map<String, dynamic>> _availableTrainers = [];

  @override
  void initState() {
    super.initState();
    _fetchTrainers();
  }

  Future<void> _fetchTrainers() async {
    setState(() {
      _loadingTrainers = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Trainer')
          .get();

      setState(() {
        _availableTrainers = querySnapshot.docs
            .map((doc) => {
          'id': doc.id,
          'name': '${doc.data()['firstName']} ${doc.data()['lastName']}',
        })
            .toList();
      });
    } catch (e) {
      print('Error fetching trainers: $e');
    } finally {
      setState(() {
        _loadingTrainers = false;
      });
    }
  }

  String? _getTrainerIdByName(String trainerName) {
    for (var trainer in _availableTrainers) {
      if (trainer['name'] == trainerName) {
        return trainer['id'] as String?;
      }
    }
    return null;
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  bool _isValidEmail(String email) {
    // First check basic email format
    if (!EmailValidator.validate(email)) {
      return false;
    }

    // Then check if it's a Gmail address
    return email.toLowerCase().endsWith('@gmail.com');
  }

  // This function checks if the email exists by attempting to send a verification email
  Future<bool> _checkEmailExists(String email) async {
    try {
      setState(() {
        _isVerifyingEmail = true;
      });

      // This will throw an error if the email doesn't exist in Firebase Auth
      // We will use signInWithEmailAndPassword with an invalid password to check if email exists
      // Note: This is a common technique but has limitations
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: 'temporaryInvalidPassword123!',
        );
        // If we get here, the email exists and the password was somehow correct (extremely unlikely)
        return true;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // Email doesn't exist in Firebase
          return false;
        } else if (e.code == 'wrong-password') {
          // Email exists but password is wrong (which is expected)
          return true;
        }
        return false; // Other errors
      }
    } finally {
      setState(() {
        _isVerifyingEmail = false;
      });
    }
  }

  bool _isOldEnough(String dob) {
    try {
      final birthDate = DateTime.parse(dob);
      final age = DateTime.now().year - birthDate.year;
      return age >= 12;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _validateFields() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("All fields are required."),
      ));
      return false;
    }

    if (!_isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter a valid Gmail address (e.g., example@gmail.com)."),
      ));
      return false;
    }

    // Check if the email exists
    bool emailExists = await _checkEmailExists(_emailController.text);
    if (emailExists) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("This email is already in use. Please use a different email or sign in."),
      ));
      return false;
    }

    if (!_isOldEnough(_dobController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("You must be at least 12 years old."),
      ));
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Passwords do not match."),
      ));
      return false;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Password must be at least 6 characters long."),
      ));
      return false;
    }

    if (_selectedRole == 'Trainee' && _selectedCoach == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please select a coach."),
      ));
      return false;
    }

    return true;
  }

  Future<void> _createAccount() async {
    bool isValid = await _validateFields();
    if (!isValid) return;

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        // Send email verification
        await user.sendEmailVerification();

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'firstName': _firstNameController.text.trim(),
          'middleName': _middleNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'dob': _dobController.text.trim(),
          'role': _selectedRole,
          'coachName': _selectedCoach,
          'coachId': _selectedRole == 'Trainee' ? _getTrainerIdByName(_selectedCoach!) : null,
          'disease': _selectedDisease,
          'otherDisease': _otherDiseaseController.text.trim(),
          'emailVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Sign out the user so they have to verify their email
        await FirebaseAuth.instance.signOut();

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Account created successfully! Please verify your email before signing in."),
          backgroundColor: Colors.green,
        ));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred during sign up.";
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: ${e.toString()}"),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
            children: <Widget>[
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    themeProvider.themeMode == ThemeMode.light
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () => themeProvider.toggleTheme(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Create Account',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Let's Start!",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 20,
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
                    _buildTextField(_firstNameController, 'First Name', Icons.person),
                    const SizedBox(height: 20),
                    _buildTextField(_middleNameController, 'Middle Name', Icons.person_outline),
                    const SizedBox(height: 20),
                    _buildTextField(_lastNameController, 'Last Name', Icons.person_outline),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _selectDateOfBirth(context),
                      child: AbsorbPointer(
                        child: _buildTextField(_dobController, 'Date of Birth', Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownField(
                      label: "Select Role",
                      value: _selectedRole,
                      items: ["Trainer", "Trainee", "Self-Trainee"],
                      icon: Icons.work,
                      onChanged: (value) => setState(() {
                        _selectedRole = value;
                        if (_selectedRole == 'Self-Trainee') _selectedCoach = null;
                      }),
                    ),
                    const SizedBox(height: 20),
                    if (_selectedRole == 'Trainee')
                      _loadingTrainers
                          ? const Center(child: CircularProgressIndicator())
                          : _availableTrainers.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "No trainers available. Please check back later.",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      )
                          : _buildDropdownField(
                        label: "Select Coach",
                        value: _selectedCoach,
                        items: _availableTrainers.map((t) => t['name'] as String).toList(),
                        icon: Icons.sports,
                        onChanged: (value) => setState(() => _selectedCoach = value),
                      ),
                    if (_selectedRole == 'Trainee') const SizedBox(height: 20),
                    _buildDiseasesDropdown(),
                    if (_selectedDisease == 'Other') ...[
                      const SizedBox(height: 20),
                      _buildTextField(_otherDiseaseController, 'Please specify the disease', Icons.text_fields),
                    ],
                    const SizedBox(height: 20),
                    _buildTextField(_phoneController, 'Phone Number', Icons.phone),
                    const SizedBox(height: 20),
                    _buildEmailField(),
                    const SizedBox(height: 20),
                    _buildTextField(_passwordController, 'Password', Icons.lock, obscureText: true),
                    const SizedBox(height: 20),
                    _buildTextField(_confirmPasswordController, 'Confirm Password', Icons.lock, obscureText: true),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "By continuing, you agree to Terms of Use and Privacy Policy.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 30),
              MaterialButton(
                color: Colors.white,
                elevation: 5.0,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                onPressed: (_isLoading || _isVerifyingEmail) ? null : _createAccount,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Color(0xFF232323),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInScreen()),
                    ),
                    child: Text(
                      'Log in',
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

  Widget _buildEmailField() {
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
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                // Reset verification state when email changes
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Gmail Address',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.email, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                suffixIcon: _emailController.text.isNotEmpty
                    ? _isValidEmail(_emailController.text)
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.error, color: Colors.red)
                    : null,
              ),
            ),
          ),
          if (_isVerifyingEmail)
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool obscureText = false,
      }) {
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
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.black), // Black text color for input
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey), // Grey hint text
          prefixIcon: Icon(icon, color: Colors.grey), // Grey icon
          border: InputBorder.none, // Remove default border
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required IconData icon,
    String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // White background for dropdown
        borderRadius: BorderRadius.circular(15), // Rounded corners (15px radius)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Optional: Add a subtle shadow
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey), // Grey hint text
          prefixIcon: Icon(icon, color: Colors.grey), // Grey icon
          border: InputBorder.none, // Remove default border
        ),
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDiseasesDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // White background for dropdown
        borderRadius: BorderRadius.circular(15), // Rounded corners (15px radius)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Optional: Add a subtle shadow
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          hintText: 'Select Disease',
          hintStyle: TextStyle(color: Colors.grey), // Grey hint text
          border: InputBorder.none, // Remove default border
        ),
        value: _selectedDisease,
        items: _diseases.map((disease) {
          return DropdownMenuItem(
            value: disease,
            child: Text(disease),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedDisease = value;
          });
        },
      ),
    );
  }
}