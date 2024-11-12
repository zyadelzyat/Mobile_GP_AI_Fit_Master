import 'package:flutter/material.dart';
import 'signin_screen.dart'; // Import the SignIn screen
import 'package:intl/intl.dart'; // Import for DateFormat

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

  String? _selectedRole;
  String? _selectedCoach;
  final List<String> _diseases = ['No Diseases', 'Heart Diseases', 'Diabetes', 'Blood Pressure', 'Other'];
  final List<String> _selectedDiseases = []; // To store selected diseases

  // Date of Birth Picker
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
              const SizedBox(height: 20),
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context); // This will pop the current screen and navigate back
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Create Account',
                style: TextStyle(
                  color: Colors.lime, // Lime green color for the title
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // "Let's start!" text
              const Text(
                "Let's Start!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // Purple Background behind Text Fields
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFB39DDB), // Light purple background color
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // First Name input
                    _buildTextField(_firstNameController, 'First Name', Icons.person),
                    const SizedBox(height: 20),

                    // Middle Name input
                    _buildTextField(_middleNameController, 'Middle Name', Icons.person_outline),
                    const SizedBox(height: 20),

                    // Last Name input
                    _buildTextField(_lastNameController, 'Last Name', Icons.person_outline),
                    const SizedBox(height: 20),

                    // Date of Birth input
                    GestureDetector(
                      onTap: () => _selectDateOfBirth(context),
                      child: AbsorbPointer(
                        child: _buildTextField(_dobController, 'Date of Birth', Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Role selection
                    _buildDropdownField(
                      label: "Select Role",
                      value: _selectedRole,
                      items: ["Trainer", "Trainee", "Self-Trainee"],
                      icon: Icons.work,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Coach Name selection
                    _buildDropdownField(
                      label: "Select Coach Name",
                      value: _selectedCoach,
                      items: ["Coach A", "Coach B", "Coach C"], // Sample coaches
                      icon: Icons.sports,
                      onChanged: (value) {
                        setState(() {
                          _selectedCoach = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Diseases multi-select in a box
                    _buildDiseasesMultiSelectBox(),
                    const SizedBox(height: 20),

                    // Phone Number input
                    _buildTextField(_phoneController, 'Phone Number', Icons.phone),
                    const SizedBox(height: 20),

                    // Email input
                    _buildTextField(_emailController, 'Email', Icons.email),
                    const SizedBox(height: 20),

                    // Password input
                    _buildTextField(_passwordController, 'Password', Icons.lock, obscureText: true),
                    const SizedBox(height: 20),

                    // Confirm Password input
                    _buildTextField(_confirmPasswordController, 'Confirm Password', Icons.lock, obscureText: true),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Terms and conditions text
              const Text(
                "By continuing, you agree to Terms of Use and Privacy Policy.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 30),

              // Sign Up Button
              MaterialButton(
                color: Colors.white,
                elevation: 5.0,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                onPressed: () {
                  // Handle sign-up logic
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInScreen()),
                  );
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Color(0xFF232323),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Or sign up with
              const Text(
                "Or sign up with",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 10),

              // Sign up with other methods
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.facebook, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Already have an account prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SignInScreen()),
                      );
                    },
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        color: Colors.lime,
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

  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon, {bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDiseasesMultiSelectBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Diseases (if any)",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ..._diseases.map((disease) {
            return CheckboxListTile(
              title: Text(disease),
              value: _selectedDiseases.contains(disease),
              onChanged: (isSelected) {
                setState(() {
                  if (isSelected!) {
                    _selectedDiseases.add(disease);
                  } else {
                    _selectedDiseases.remove(disease);
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            );
          }),
        ],
      ),
    );
  }
}
