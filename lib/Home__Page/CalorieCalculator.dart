import 'package:flutter/material.dart';
import 'package:untitled/Home__Page/SupplementsStore.dart';
import 'package:untitled/Home__Page/SupplementsStore.dart'; // تأكد من أن هذا المسار صحيح
import '00_home_page.dart'; // Adjust the path as needed

class CalorieCalculatorPage extends StatefulWidget {
  @override
  _CalorieCalculatorPageState createState() => _CalorieCalculatorPageState();
}

class _CalorieCalculatorPageState extends State<CalorieCalculatorPage> {
  // Controllers for input fields
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Variables for storing selected values and the result
  String _gender = 'male'; // Default: male
  String _activityLevel = 'Sedentary'; // Default activity level
  double? _calories; // Will store the calculated daily calories

  // Function to calculate calories based on the Mifflin-St Jeor equation
  void _calculateCalories() {
    final int age = int.tryParse(_ageController.text) ?? 0;
    final double height = double.tryParse(_heightController.text) ?? 0.0;
    final double weight = double.tryParse(_weightController.text) ?? 0.0;

    double bmr;
    if (_gender == 'male') {
      // Mifflin-St Jeor for males
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      // Mifflin-St Jeor for females
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    // Determine activity factor
    double activityFactor;
    switch (_activityLevel) {
      case 'Lightly Active':
        activityFactor = 1.375;
        break;
      case 'Moderately Active':
        activityFactor = 1.55;
        break;
      case 'Very Active':
        activityFactor = 1.725;
        break;
      case 'Extra Active':
        activityFactor = 1.9;
        break;
      default: // Sedentary
        activityFactor = 1.2;
    }

    // Calculate final daily calories
    double finalCalories = bmr * activityFactor;

    setState(() {
      _calories = finalCalories;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Custom light purple color (adjust as needed)
    final Color customPurple = const Color(0xFFB892FF);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        // Adding a back arrow that navigates to the products page
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()), // Navigate to home page
            );
          },
        ),
        title: const Text('Calorie Calculator'),
        backgroundColor: customPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your data to calculate your daily calorie needs:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Age field
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Age',
                labelStyle: const TextStyle(color: Colors.white),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: customPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: customPurple, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Gender selection
            Row(
              children: [
                const Text('Gender:', style: TextStyle(color: Colors.white)),
                Expanded(
                  child: RadioListTile<String>(
                    activeColor: customPurple,
                    title: const Text('Male', style: TextStyle(color: Colors.white)),
                    value: 'male',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    activeColor: customPurple,
                    title: const Text('Female', style: TextStyle(color: Colors.white)),
                    value: 'female',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Height field
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Height (cm)',
                labelStyle: const TextStyle(color: Colors.white),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: customPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: customPurple, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Weight field
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                labelStyle: const TextStyle(color: Colors.white),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: customPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: customPurple, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Activity level dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: customPurple),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButton<String>(
                dropdownColor: Colors.black,
                value: _activityLevel,
                items: <String>[
                  'Sedentary',
                  'Lightly Active',
                  'Moderately Active',
                  'Very Active',
                  'Extra Active'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _activityLevel = value!;
                  });
                },
                underline: const SizedBox(), // Remove default underline
                iconEnabledColor: customPurple,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            // Calculate button
            Center(
              child: ElevatedButton(
                onPressed: _calculateCalories,
                style: ElevatedButton.styleFrom(
                  backgroundColor: customPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Calculate',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Display result
            if (_calories != null)
              Center(
                child: Text(
                  'Your daily calories: ${_calories!.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
