import 'package:flutter/material.dart';
// Adjust the path as needed

class CalorieCalculatorPage extends StatefulWidget {
  const CalorieCalculatorPage({super.key});

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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: const Color(0xFF8E7AFE)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF8E7AFE), width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityLevelDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.fitness_center, color: Color(0xFF8E7AFE)),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: const Color(0xFF2A2A2A),
                isExpanded: true,
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
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF8E7AFE)),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.person, color: Color(0xFF8E7AFE)),
          const SizedBox(width: 12),
          const Text(
            'Gender:',
            style: TextStyle(color: Colors.grey),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    activeColor: const Color(0xFF8E7AFE),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Male', style: TextStyle(color: Colors.white, fontSize: 14)),
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
                    activeColor: const Color(0xFF8E7AFE),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Female', style: TextStyle(color: Colors.white, fontSize: 14)),
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
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    if (_calories == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E7AFE), Color(0xFF6A5AE0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E7AFE).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Your Daily Calorie Needs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_fire_department, color: Colors.white, size: 36),
              const SizedBox(width: 8),
              Text(
                _calories!.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                ' kcal',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getCalorieMessage(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getCalorieMessage() {
    if (_calories == null) return '';

    final double weight = double.tryParse(_weightController.text) ?? 0.0;

    if (_activityLevel == 'Sedentary') {
      return 'Based on your sedentary lifestyle, try to stay active throughout the day to reach your fitness goals.';
    } else if (_activityLevel == 'Very Active' || _activityLevel == 'Extra Active') {
      return 'Your active lifestyle requires significant energy. Make sure to fuel properly with protein and complex carbs.';
    } else {
      return 'This is your maintenance calorie need. Adjust by 300-500 calories for weight goals.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      appBar: AppBar(
        backgroundColor: const Color(0xFF232323),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Calorie Calculator',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Calculate Your Daily Calorie Needs',
                style: TextStyle(
                  color: Color(0xFF8E7AFE),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fill in your details to get an accurate estimation',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              _buildGenderSelector(),

              _buildTextField(
                controller: _ageController,
                label: 'Age (years)',
                icon: Icons.cake,
                keyboardType: TextInputType.number,
              ),

              _buildTextField(
                controller: _heightController,
                label: 'Height (cm)',
                icon: Icons.height,
                keyboardType: TextInputType.number,
              ),

              _buildTextField(
                controller: _weightController,
                label: 'Weight (kg)',
                icon: Icons.fitness_center,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 8),
              const Text(
                'Activity Level',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              _buildActivityLevelDropdown(),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _calculateCalories,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E7AFE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'CALCULATE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }
}