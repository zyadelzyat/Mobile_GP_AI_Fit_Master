import 'package:flutter/material.dart';
import '06 WeightSelectionScreen.dart'; // Import WeightSelectionScreen

void main() {
  runApp(HeightSelectionApp());
}

class HeightSelectionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HeightSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HeightSelectionScreen extends StatefulWidget {
  @override
  _HeightSelectionScreenState createState() => _HeightSelectionScreenState();
}

class _HeightSelectionScreenState extends State<HeightSelectionScreen> {
  int selectedHeight = 165; // Default height in cm

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323), // Set background to #232323
      appBar: AppBar(
        backgroundColor: const Color(0xFF232323), // Set AppBar background to #232323
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
              "What Is Your Height?",
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
                "Select your height from the options below.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
            // Height Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  selectedHeight.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Cm",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Ruler Design with ListWheelScrollView
            Container(
              height: 160, // Increased height to accommodate better spacing
              decoration: BoxDecoration(
                color: const Color(0xFFB3A0FF), // Ruler background color
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
                  // Height Picker (ListWheelScrollView inside the ruler)
                  Positioned.fill(
                    child: SizedBox(
                      height: 120,
                      child: ListWheelScrollView.useDelegate(
                        controller: FixedExtentScrollController(initialItem: selectedHeight - 140),
                        itemExtent: 40,
                        physics: const FixedExtentScrollPhysics(),
                        perspective: 0.003,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedHeight = 140 + index;
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            return Center(
                              child: Text(
                                (140 + index).toString(),
                                style: TextStyle(
                                  color: selectedHeight == 140 + index
                                      ? Colors.yellow
                                      : Colors.white54,
                                  fontSize: 20,
                                ),
                              ),
                            );
                          },
                          childCount: 101, // From 140 cm to 240 cm
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
                // Navigate to WeightSelectionScreen on Continue button press
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WeightSelectionScreen(gender: '',), // Navigate to WeightSelectionScreen
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800], // Button color
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
