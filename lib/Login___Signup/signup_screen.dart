import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider for state management
import '01_signin_screen.dart'; // Import SignIn screen
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:untitled/theme_provider.dart'; // Import ThemeProvider for theme management

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

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
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

  bool _validateFields() {
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
        content: Text("Please enter a valid email address."),
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

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Access ThemeProvider

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Use theme background color
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),

              // Theme Toggle Button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    themeProvider.themeMode == ThemeMode.light
                        ? Icons.dark_mode // Dark mode icon
                        : Icons.light_mode, // Light mode icon
                    color: Theme.of(context).iconTheme.color, // Use theme icon color
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme(); // Toggle between light and dark mode
                  },
                ),
              ),

              const SizedBox(height: 20),
              Text(
                'Create Account',
                style: TextStyle(
                  color: Theme.of(context).primaryColor, // Use theme primary color
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Let's Start!",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color, // Use theme text color
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFB39DDB), // Light purple background color
                  borderRadius: BorderRadius.circular(20), // Rounded corners
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
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value;
                          if (_selectedRole == 'Self-Trainee') {
                            _selectedCoach = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    if (_selectedRole != 'Self-Trainee')
                      _buildDropdownField(
                        label: "Select Coach Name",
                        value: _selectedCoach,
                        items: ["Coach A", "Coach B", "Coach C"],
                        icon: Icons.sports,
                        onChanged: (value) => setState(() => _selectedCoach = value),
                      ),
                    const SizedBox(height: 20),
                    _buildDiseasesDropdown(),
                    if (_selectedDisease == 'Other') ...[
                      const SizedBox(height: 20),
                      _buildTextField(_otherDiseaseController, 'Please specify the disease', Icons.text_fields),
                    ],
                    const SizedBox(height: 20),
                    _buildTextField(_phoneController, 'Phone Number', Icons.phone),
                    const SizedBox(height: 20),
                    _buildTextField(_emailController, 'Email', Icons.email),
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
                  color: Theme.of(context).textTheme.bodyLarge?.color, // Use theme text color
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 30),
              MaterialButton(
                color: Colors.white, // White background for the button
                elevation: 5.0,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                onPressed: () {
                  if (_validateFields()) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInScreen()),
                    );
                  }
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Color(0xFF232323), // Black text for the button
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Or sign up with",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color, // Use theme text color
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: const Icon(Icons.g_mobiledata, color: Colors.white), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.facebook, color: Colors.white), onPressed: () {}),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color, // Use theme text color
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
                        color: Theme.of(context).primaryColor, // Use theme primary color
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