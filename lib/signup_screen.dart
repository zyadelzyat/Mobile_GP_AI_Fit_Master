import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323), // Set the main background color
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 30),

              // Title
              const Text(
                'Create Account',
                style: TextStyle(
                  color: Colors.lime, // Lime green color for the title
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // "Let's start!" text
              const Text(
                "Let's start!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // Name input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Set the background color for the input box
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Name',
                    prefixIcon: Icon(Icons.person),
                    border: InputBorder.none, // Remove border for container
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Age input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Age',
                    prefixIcon: Icon(Icons.date_range),
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 30),

              // Gender dropdown input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    hintText: 'Select Gender',
                    prefixIcon: Icon(Icons.person_outline),
                    border: InputBorder.none,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedGender,
                      hint: const Text('Select Gender'),
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedGender = newValue;
                        });
                      },
                      items: <String>['Male', 'Female']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Phone input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Email input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Password input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: InputBorder.none,
                  ),
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 30),

              // Confirm Password input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock),
                    border: InputBorder.none,
                  ),
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 50),

              // Terms and Conditions
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'By continuing, you agree to ',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Terms of Use',
                    style: TextStyle(color: Colors.lime), // Lime green for Terms of Use
                  ),
                  Text(
                    ' and ',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Privacy Policy',
                    style: TextStyle(color: Colors.lime), // Lime green for Privacy Policy
                  ),
                  Text(
                    '.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sign Up Button
              MaterialButton(
                color: const Color(0xFF232323), // Set the background color to match the page
                elevation: 5.0,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 80),
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                onPressed: () {
                  // Handle sign-up logic
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.white, // Text color in white for contrast
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Sign up with Facebook and Google
              const Text(
                'Or sign up with',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Handle Facebook sign up logic
                    },
                    child: Container(
                      width: 50, // Set width for small circle
                      height: 50, // Set height for small circle
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle, // Make it a circle
                        color: Colors.white,
                      ),
                      child: const Center(
                        child: Icon(Icons.facebook, color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      // Handle Google sign up logic
                    },
                    child: Container(
                      width: 50, // Set width for small circle
                      height: 50, // Set height for small circle
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle, // Make it a circle
                        color: Colors.white,
                      ),
                      child: const Center(
                        child: Icon(Icons.mail, color: Colors.red), // Placeholder for Google icon
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Already have an account prompt
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Log in',
                    style: TextStyle(color: Colors.lime), // Lime green for Log in
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
