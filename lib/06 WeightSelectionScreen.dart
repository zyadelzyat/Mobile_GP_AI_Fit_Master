import 'package:flutter/material.dart';
import '07 GoalSelectionScreen.dart'; // Import GoalSelectionScreen

class WeightSelectionScreen extends StatefulWidget {
  final String gender;

  const WeightSelectionScreen({required this.gender});

  @override
  _WeightSelectionScreenState createState() => _WeightSelectionScreenState();
}

class _WeightSelectionScreenState extends State<WeightSelectionScreen> {
  bool isKg = true;
  double selectedWeight = 75;
  double minWeight = 50;
  double maxWeight = 300;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      appBar: AppBar(
        backgroundColor: const Color(0xFF232323),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.yellow),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Text(
              "What Is Your Weight?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Description
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Select your weight from the options below.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            // Toggle Buttons for KG and LB
            ToggleButtons(
              isSelected: [isKg, !isKg],
              onPressed: (index) {
                setState(() {
                  isKg = index == 0;
                });
              },
              borderRadius: BorderRadius.circular(30),
              fillColor: const Color(0xFFE2F163),
              selectedColor: Colors.black,
              color: Colors.white,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "KG",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "LB",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Weight Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  selectedWeight.toStringAsFixed(0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isKg ? "Kg" : "Lb",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Ruler for weight selection (interactive)
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFB3A0FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ruler background with tick marks
                  Positioned.fill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(10, (index) {
                        return Container(
                          height: 60,
                          width: 2,
                          color: Colors.white,
                        );
                      }),
                    ),
                  ),
                  // Weight Picker (ListWheelScrollView inside the ruler)
                  Positioned.fill(
                    child: SizedBox(
                      height: 120,
                      child: ListWheelScrollView.useDelegate(
                        controller: FixedExtentScrollController(
                          initialItem: (selectedWeight - minWeight).toInt(), // Convert to int
                        ),
                        itemExtent: 40,
                        physics: const FixedExtentScrollPhysics(),
                        perspective: 0.003,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedWeight = minWeight + index.toDouble();
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            double weight = minWeight + index;
                            return Center(
                              child: Text(
                                weight.toStringAsFixed(0),
                                style: TextStyle(
                                  color: selectedWeight == weight
                                      ? Colors.yellow
                                      : Colors.white54,
                                  fontSize: 20,
                                ),
                              ),
                            );
                          },
                          childCount: (maxWeight - minWeight).toInt() + 1, // From 50 kg to 300 kg
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Continue Button
            ElevatedButton(
              onPressed: () {
                // Navigate to GoalSelectionScreen on Continue button press
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoalSelectionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Continue",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
