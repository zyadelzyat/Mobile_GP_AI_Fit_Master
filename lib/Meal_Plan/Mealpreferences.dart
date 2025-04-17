import 'package:flutter/material.dart';
import 'package:untitled/Meal_Plan/plan_loading_page.dart';


class MealPreferencesPage extends StatefulWidget {
  @override
  _MealPreferencesPageState createState() => _MealPreferencesPageState();
}

class _MealPreferencesPageState extends State<MealPreferencesPage> {
  String dietaryPreference = 'No preferences';
  Set<String> allergies = {};
  Set<String> mealTypes = {'Breakfast'};

  String caloricGoal = 'Less than 1500 calories';
  String cookingTime = 'Less than 15 minutes';
  String servings = '1';

  final dietaryOptions = [
    'Vegetarian', 'Vegan', 'Gluten-Free', 'Keto', 'Paleo', 'No preferences'
  ];

  final allergyOptions = [
    'Nuts', 'Dairy', 'Shellfish', 'Eggs', 'No allergies'
  ];

  final mealTypeOptions = [
    'Breakfast', 'Lunch', 'Dinner', 'Snacks'
  ];

  final caloricOptions = [
    'Less than 1500 calories',
    '1500-2000 calories',
    'More than 2000 calories',
    'Not sure/Don’t have a goal'
  ];

  final cookingTimeOptions = [
    'Less than 15 minutes',
    '15-30 minutes',
    'More than 30 minutes'
  ];

  final servingOptions = [
    '1', '2', '3-4', 'More than 4'
  ];

  void toggleAllergy(String value) {
    setState(() {
      if (value == 'No allergies') {
        allergies.clear();
        allergies.add(value);
      } else {
        allergies.remove('No allergies');
        if (allergies.contains(value)) {
          allergies.remove(value);
        } else {
          allergies.add(value);
        }
      }
    });
  }

  void toggleMealType(String value) {
    setState(() {
      if (mealTypes.contains(value)) {
        mealTypes.remove(value);
      } else {
        mealTypes.add(value);
      }
    });
  }

  Widget buildRadioSection(String title, String subtitle, List<String> options, String selectedValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text(subtitle, style: TextStyle(color: Colors.white70)),
        SizedBox(height: 10),
        Column(
          children: options.map((option) => RadioListTile<String>(
            title: Text(option, style: TextStyle(color: Colors.white)),
            value: option,
            groupValue: selectedValue,
            activeColor: Colors.yellowAccent,
            onChanged: (value) => onChanged(value!),
          )).toList(),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.yellowAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Meal Plans', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
        actions: [
          Icon(Icons.search, color: Colors.purpleAccent),
          SizedBox(width: 10),
          Icon(Icons.notifications, color: Colors.purpleAccent),
          SizedBox(width: 10),
          Icon(Icons.person, color: Colors.purpleAccent),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSection('Dietary Preferences', dietaryOptions, dietaryPreference, (val) {
              setState(() => dietaryPreference = val);
            }, singleChoice: true),
            SizedBox(height: 24),
            buildSection('Allergies', allergyOptions, allergies, toggleAllergy),
            SizedBox(height: 24),
            buildSection('Meal Types', mealTypeOptions, mealTypes, toggleMealType),
            SizedBox(height: 30),
            buildRadioSection('Caloric Goal', 'What is your daily caloric intake goal?', caloricOptions, caloricGoal, (val) => setState(() => caloricGoal = val)),
            SizedBox(height: 24),
            buildRadioSection('Cooking Time Preference', 'How much time are you willing to spend cooking each meal?', cookingTimeOptions, cookingTime, (val) => setState(() => cookingTime = val)),
            SizedBox(height: 24),
            buildRadioSection('Number Of Servings', 'How many servings do you need per meal?', servingOptions, servings, (val) => setState(() => servings = val)),
            SizedBox(height: 30),
            Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PlanLoadingPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellowAccent,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: StadiumBorder(),
                  ),
                  child: Text('Create'),
                ),
              )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.purpleAccent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.headset), label: ''),
        ],
      ),
    );
  }

  Widget buildSection(String title, List<String> options, dynamic selected, Function(String) onChanged, {bool singleChoice = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text(
          title == 'Dietary Preferences'
              ? 'What are your dietary preferences?'
              : title == 'Allergies'
              ? 'Do you have any food allergies we should know about?'
              : 'Which meals do you want to plan?',
          style: TextStyle(color: Colors.white70),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((option) {
            final isSelected = singleChoice ? selected == option : selected.contains(option);
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Icon(Icons.check, size: 18, color: Colors.black),
                    ),
                  Text(option),
                ],
              ),
              labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.purpleAccent),
              selected: isSelected,
              selectedColor: Colors.yellowAccent,
              backgroundColor: Colors.transparent,
              shape: StadiumBorder(side: BorderSide(color: Colors.purpleAccent)),
              onSelected: (_) => onChanged(option),
            );
          }).toList(),
        )
      ],
    );
  }
}
