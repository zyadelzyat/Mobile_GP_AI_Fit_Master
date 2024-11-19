import 'package:flutter/material.dart';
import 'GenderSelectionScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FitnessScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FitnessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الجزء الخاص بالصورة
          Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/fitness_image.jpg'), // ضع هنا مسار الصورة
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // الجزء الخاص بالرسالة التحفيزية
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Consistency Is\nThe Key To Progress.\nDon't Give Up!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.limeAccent,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Nothing is impossible with determination and willpower.\nEven the toughest goals can be achieved if you stay committed.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // زر "Next"
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // عند الضغط على الزر، الانتقال لصفحة تحديد الجنس
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GenderSelectionScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
