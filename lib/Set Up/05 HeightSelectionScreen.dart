import 'package:flutter/material.dart';
import '06 WeightSelectionScreen.dart'; // Import WeightSelectionScreen

void main() {
  runApp(const HeightSelectionApp());
}

class HeightSelectionApp extends StatelessWidget {
  const HeightSelectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HeightSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HeightSelectionScreen extends StatefulWidget {
  const HeightSelectionScreen({super.key});

  @override
  _HeightSelectionScreenState createState() => _HeightSelectionScreenState();
}

class _HeightSelectionScreenState extends State<HeightSelectionScreen> {
  int selectedHeight = 165; // Default height in cm

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF232323), // Background color
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
                // Ruler Design with Vertical ListWheelScrollView
                SizedBox(
                  height: 300, // Smaller height for the ruler
                  child: Center(
                    child: Container(
                      width: 100, // Width of the ruler
                      decoration: BoxDecoration(
                        color: const Color(0xFFB3A0FF), // Ruler background color
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Vertical ListWheelScrollView for height selection
                          ListWheelScrollView.useDelegate(
                            controller: FixedExtentScrollController(initialItem: selectedHeight - 140),
                            itemExtent: 40, // Spacing between items
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
                          // Center Marker
                          Positioned(
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              color: Colors.yellow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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