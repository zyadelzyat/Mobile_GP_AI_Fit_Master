import 'package:flutter/material.dart';
import 'package:untitled/WeightSelectionScreen.dart';
import 'package:untitled/GoalSelectionScreen.dart';


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
  int selectedHeight = 165;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.yellow),
          onPressed: () {},
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "What Is Your Height?",
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
          SizedBox(height: 40),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  selectedHeight.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "Cm",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 150,
            child: ListWheelScrollView.useDelegate(
              controller: FixedExtentScrollController(initialItem: selectedHeight - 140),
              itemExtent: 40,
              physics: FixedExtentScrollPhysics(),
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
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              // عند الضغط على زر Continue، سيتم الانتقال إلى صفحة GoalSelectionScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoalSelectionScreen(), // هنا سيتم الانتقال إلى الصفحة التي ترغب فيها
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800], // الصيغة الصحيحة
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


          SizedBox(height: 20),
        ],
      ),
    );
  }
}
