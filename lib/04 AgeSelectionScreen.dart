import 'package:flutter/material.dart';
import '05 HeightSelectionScreen.dart'; // Import the height selection screen

class AgeSelectionScreen extends StatefulWidget {
  const AgeSelectionScreen({super.key});

  @override
  _AgeSelectionScreenState createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  int selectedAge = 18; // Default age selection, starting from 18

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323), // Dark background color
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          const Text(
            "How Old Are You?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          // Description
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              "Select your age from the options below to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Selected Age Display
          Text(
            selectedAge.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Ruler-like design with ListWheelScrollView
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ruler background with color #B3A0FF
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3A0FF), // Ruler background color
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(10, (index) {
                      return Container(
                        height: 50,
                        width: 2,
                        color: Colors.white,
                      );
                    }),
                  ),
                ),
                // Age Picker (ListWheelScrollView inside the ruler)
                SizedBox(
                  height: 120,
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 50,
                    physics: const FixedExtentScrollPhysics(),
                    perspective: 0.003,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedAge = index + 18; // Start from 18
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        final age = index + 18; // Age range starts at 18
                        return Center(
                          child: Text(
                            age.toString(),
                            style: TextStyle(
                              fontSize: 30,
                              color: age == selectedAge
                                  ? const Color(0xFFE2F163) // Highlighted color
                                  : Colors.white70,
                              fontWeight: age == selectedAge
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        );
                      },
                      childCount: 83, // 18 to 100
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HeightSelectionScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF424242), // Dark button color
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              shadowColor: Colors.black.withOpacity(0.5),
              elevation: 8,
            ),
            child: const Text(
              "Continue",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
