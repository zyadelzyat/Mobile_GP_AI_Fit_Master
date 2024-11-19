import 'package:flutter/material.dart';
import 'HeightSelectionScreen.dart';

class WeightSelectionScreen extends StatefulWidget {
  final String gender; // لاستقبال الجنس من الصفحة السابقة

  const WeightSelectionScreen({required this.gender}); // استقبال الجنس كـ "required"

  @override
  _WeightSelectionScreenState createState() => _WeightSelectionScreenState();
}

class _WeightSelectionScreenState extends State<WeightSelectionScreen> {
  bool isKg = true;
  double selectedWeight = 75;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.yellow),
          onPressed: () {
            Navigator.pop(context); // الرجوع للصفحة السابقة
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "What Is Your Weight?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
          ),
          SizedBox(height: 30),
          ToggleButtons(
            isSelected: [isKg, !isKg],
            onPressed: (index) {
              setState(() {
                isKg = index == 0;
              });
            },
            borderRadius: BorderRadius.circular(30),
            fillColor: Colors.yellow,
            selectedColor: Colors.black,
            color: Colors.white,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "KG",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "LB",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbColor: Colors.yellow,
              activeTrackColor: Colors.purple,
              inactiveTrackColor: Colors.purple.withOpacity(0.3),
              trackHeight: 6,
              overlayColor: Colors.yellow.withOpacity(0.2),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: selectedWeight,
              min: 50,
              max: 150,
              divisions: 100,
              label: selectedWeight.round().toString(),
              onChanged: (value) {
                setState(() {
                  selectedWeight = value;
                });
              },
            ),
          ),
          SizedBox(height: 10),
          Text(
            "${selectedWeight.round()} ${isKg ? 'Kg' : 'Lb'}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HeightSelectionScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              "Continue",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
