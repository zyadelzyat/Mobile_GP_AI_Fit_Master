import 'package:flutter/material.dart';
import 'WeightSelectionScreen.dart'; // استيراد الصفحة الخاصة بتحديد الوزن

void main() {
  runApp(GenderSelectionApp());
}

class GenderSelectionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GenderSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GenderSelectionScreen extends StatefulWidget {
  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? selectedGender; // لتخزين الجنس المحدد

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
            Navigator.pop(context); // العودة إلى الصفحة السابقة
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "What's Your Gender",
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
              "Always keep your goal in sight and ask yourself daily: What did I do today to get closer to that goal?",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
          ),
          SizedBox(height: 40),
          GenderOption(
            icon: Icons.male,
            label: "Male",
            color: Colors.white,
            isSelected: selectedGender == 'Male',
            onTap: () {
              setState(() {
                selectedGender = 'Male'; // تعيين الجنس المختار
              });
            },
          ),
          SizedBox(height: 20),
          GenderOption(
            icon: Icons.female,
            label: "Female",
            color: Colors.yellow,
            isSelected: selectedGender == 'Female',
            onTap: () {
              setState(() {
                selectedGender = 'Female'; // تعيين الجنس المختار
              });
            },
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              if (selectedGender != null) {
                // إذا تم اختيار الجنس، الانتقال إلى صفحة تحديد الوزن
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeightSelectionScreen(gender: selectedGender!), // تمرير الجنس إلى الصفحة التالية
                  ),
                );
              } else {
                // إذا لم يتم اختيار الجنس، عرض رسالة تنبيه للمستخدم
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please select your gender")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
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

class GenderOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const GenderOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // عند الضغط على الخيار
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? color.withOpacity(0.4) : color.withOpacity(0.2), // تأثير التظليل عند الاختيار
            ),
            padding: EdgeInsets.all(30),
            child: Icon(
              icon,
              size: 50,
              color: color,
            ),
          ),
          SizedBox(width: 20),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
