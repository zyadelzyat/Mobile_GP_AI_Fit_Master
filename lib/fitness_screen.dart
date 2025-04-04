import 'package:flutter/material.dart';
import 'Set Up/03 GenderSelectionScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FitnessScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FitnessScreen extends StatelessWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Image section - takes approximately 70% of screen
          Expanded(
            flex: 7,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/fitness_image.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Text section with updated background color - takes approximately 30% of screen
          Expanded(
            flex: 3,
            child: Container(
              color: const Color(0xFF232323), // Updated to #232323
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Motivational text in yellow
                    const Text(
                      "Consistency Is\nThe Key To Progress.\nDon't Give Up!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFE5E500), // Bright yellow color
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    // Spacing
                    const SizedBox(height: 8),
                    // Subtitle text in white
                    const Text(
                      "Leave your diet at your complete relaxing life\nand watch your productivity. It helps in peace\nperfect mind.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    // Spacing
                    const SizedBox(height: 12),
                    // Next button - dark gray circular button
                    SizedBox(
                      height: 48,
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const GenderSelectionScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}