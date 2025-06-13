import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '01_signin_screen.dart';
import 'package:intl/intl.dart';
import 'package:untitled/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
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
    if (!EmailValidator.validate(email)) {
      return false;
    }
    return email.toLowerCase().endsWith('@gmail.com');
  }

  Future<bool> _checkEmailExists(String email) async {
    try {
      setState(() {
        _isVerifyingEmail = true;
      });
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: 'temporaryInvalidPassword123!',
        );
        return true;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          return false;
        } else if (e.code == 'wrong-password') {
          return true;
        }
        return false;
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
            children: [
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
                          style: TextStyle(color: Colors.white), // White text on purple background
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
        color: Colors.white, // Keep white background
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
              style: const TextStyle(color: Colors.black), // Always black text on white
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
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
        color: Colors.white, // Always white background
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.black), // Always black text on white
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
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
        color: Colors.white, // Always white background
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
        ),
        value: value,
        hint: Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
        dropdownColor: Colors.white, // Always white dropdown background
        style: const TextStyle(color: Colors.black), // Always black text
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(color: Colors.black), // Always black text
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDiseasesDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Always white background
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          hintText: 'Select Disease',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.local_hospital, color: Colors.grey),
          border: InputBorder.none,
        ),
        value: _selectedDisease,
        hint: const Text(
          'Select Disease',
          style: TextStyle(color: Colors.grey),
        ),
        dropdownColor: Colors.white, // Always white dropdown background
        style: const TextStyle(color: Colors.black), // Always black text
        items: _diseases.map((disease) {
          return DropdownMenuItem<String>(
            value: disease,
            child: Text(
              disease,
              style: const TextStyle(color: Colors.black), // Always black text
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedDisease = value;
          });
        },
      ),
    );
  }}