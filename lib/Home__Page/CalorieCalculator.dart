import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '00_home_page.dart';
import 'Store.dart';
import 'profile.dart';
import 'favorite_page.dart';

class CalorieCalculator extends StatefulWidget {
  const CalorieCalculator({super.key});

  @override
  State createState() => _CalorieCalculatorState();
}

class _CalorieCalculatorState extends State<CalorieCalculator> {
  final _weightController = TextEditingController(text: "95");
  final _heightController = TextEditingController(text: "166");
  final _ageController = TextEditingController(text: "21");
  String _gender = 'male';
  String _activityLevel = 'active';
  int proteins = 0, maxProteins = 0;
  int fats = 0, maxFats = 0;
  int carbs = 0, maxCarbs = 0;
  int calories = 0, maxCalories = 0;
  int _selectedIndex = 2;

  void _calculateCalories() {
    setState(() {
      final double weight = double.tryParse(_weightController.text) ?? 0;
      final double height = double.tryParse(_heightController.text) ?? 0;
      final int age = int.tryParse(_ageController.text) ?? 0;
      double bmr;

      if (_gender == 'male') {
        bmr = 10 * weight + 6.25 * height - 5 * age + 5;
      } else {
        bmr = 10 * weight + 6.25 * height - 5 * age - 161;
      }

      final activityMultipliers = {
        'sedentary': 1.2,
        'lightly active': 1.375,
        'active': 1.55,
        'very active': 1.725,
        'extra active': 1.9,
      };
      final multiplier = activityMultipliers[_activityLevel] ?? 1.2;
      maxCalories = (bmr * multiplier).round();
      calories = 0; // Reset display

      maxProteins = ((maxCalories * 0.3) / 4).round();
      maxFats = ((maxCalories * 0.3) / 9).round();
      maxCarbs = ((maxCalories * 0.4) / 4).round();
      proteins = 0;
      fats = 0;
      carbs = 0;
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF8E7AFE),
                fontWeight: FontWeight.w600,
                fontSize: 15)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildActivityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Activity Level',
            style: TextStyle(
                color: Color(0xFF8E7AFE),
                fontWeight: FontWeight.w600,
                fontSize: 15)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              value: _activityLevel,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              items: [
                'sedentary',
                'lightly active',
                'active',
                'very active',
                'extra active'
              ]
                  .map((level) => DropdownMenuItem(
                value: level,
                child: Text(level,
                    style: const TextStyle(color: Colors.black)),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _activityLevel = value!;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gender',
            style: TextStyle(
                color: Color(0xFF8E7AFE),
                fontWeight: FontWeight.w600,
                fontSize: 15)),
        const SizedBox(height: 4),
        Row(
          children: [
            Row(
              children: [
                Radio(
                  value: 'male',
                  groupValue: _gender,
                  activeColor: Colors.grey,
                  onChanged: (value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                ),
                const Text('Male',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ],
            ),
            const SizedBox(width: 12),
            Row(
              children: [
                Radio(
                  value: 'female',
                  groupValue: _gender,
                  activeColor: Color(0xFFEFFF4B),
                  onChanged: (value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                ),
                const Text('Female',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildMacrosCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text('$maxProteins g',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                LinearProgressIndicator(
                  value: maxProteins == 0 ? 0 : proteins / maxProteins,
                  color: Colors.orange,
                  backgroundColor: Colors.grey.shade300,
                  minHeight: 5,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('🥩', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 4),
                    Text('Proteins',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text('$maxFats g',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                LinearProgressIndicator(
                  value: maxFats == 0 ? 0 : fats / maxFats,
                  color: Color(0xFFEFFF4B),
                  backgroundColor: Colors.grey.shade300,
                  minHeight: 5,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('🥑', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 4),
                    Text('Fats',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text('$maxCarbs g',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                LinearProgressIndicator(
                  value: maxCarbs == 0 ? 0 : carbs / maxCarbs,
                  color: Color(0xFF8E7AFE),
                  backgroundColor: Colors.grey.shade300,
                  minHeight: 5,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('🍚', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 4),
                    Text('Carbs',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _calculateCalories,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEFFF4B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Calculate Now",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            SizedBox(width: 8),
            Icon(Icons.refresh, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: maxCalories == 0 ? 0 : calories / maxCalories,
            color: Color(0xFF8E7AFE),
            backgroundColor: Colors.grey.shade300,
            minHeight: 7,
          ),
          const SizedBox(height: 6),
          Text(
            "$calories / $maxCalories kcal",
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('🔥', style: TextStyle(fontSize: 16)),
              SizedBox(width: 4),
              Text('Calories',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1: // Store
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SupplementsStorePage()),
        );
        break;
      case 2: // Calculator (Current Page)
        setState(() {
          _selectedIndex = index;
        });
        break;
      case 3: // Profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(userId: FirebaseAuth.instance.currentUser?.uid ?? '')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Calorie Calculator",
                    style: TextStyle(
                        color: Color(0xFF8E7AFE),
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  const SizedBox(width: 6),
                  const Text("🍏", style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField(
                  controller: _weightController,
                  label: "Weight (kg)",
                  keyboardType: TextInputType.number),
              _buildTextField(
                  controller: _heightController,
                  label: "Height (cm)",
                  keyboardType: TextInputType.number),
              _buildTextField(
                  controller: _ageController,
                  label: "Age",
                  keyboardType: TextInputType.number,
                  suffix: const Icon(Icons.calendar_today, color: Colors.grey)),
              _buildActivityDropdown(),
              _buildGenderSelector(),
              _buildMacrosCard(),
              const SizedBox(height: 18),
              _buildCalculateButton(),
              _buildCaloriesCard(),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFB3A0FF),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20)
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1
              )
            ],
          ),
          child: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                activeIcon: Icon(Icons.shopping_bag),
                label: 'Store',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calculate_outlined),
                activeIcon: Icon(Icons.calculate),
                label: 'Calculator',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                activeIcon: Icon(Icons.favorite),
                label: 'Favorites',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.6),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
          ),
        )

    );
  }
}
