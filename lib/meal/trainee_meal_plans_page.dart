import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TraineeMealPlansPage extends StatefulWidget {
  const TraineeMealPlansPage({Key? key}) : super(key: key);

  @override
  _TraineeMealPlansPageState createState() => _TraineeMealPlansPageState();
}

class _TraineeMealPlansPageState extends State<TraineeMealPlansPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  List<Map<String, dynamic>> _mealPlans = [];

  @override
  void initState() {
    super.initState();
    _loadMealPlans();
  }

  Future<void> _loadMealPlans() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      QuerySnapshot mealPlansSnapshot = await _firestore
          .collection('meal_plans')
          .where('traineeId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> mealPlans = [];
      for (var doc in mealPlansSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        mealPlans.add(data);
      }

      setState(() {
        _mealPlans = mealPlans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildMealCard(Map<String, dynamic> meal, int index) {
    final mealType = meal['mealType'] ?? 'Meal';
    final description = meal['description'] ?? '';
    final duration = meal['duration'] ?? '';
    final calories = meal['calories']?.toString() ?? '0';
    final protein = meal['protein']?.toString() ?? '0';
    final carbs = meal['carbs']?.toString() ?? '0';
    final fat = meal['fat']?.toString() ?? '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored dot indicator (like screenshot)
          Container(
            margin: const EdgeInsets.only(top: 18),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: const Color(0xFF8E7AFE), width: 3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Meal info card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meal title and favorite star
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            description,
                            style: const TextStyle(
                              color: Color(0xFF222222),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star_border, color: Colors.black26, size: 22),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Duration & Calories
                    Row(
                      children: [
                        const SizedBox(width: 4),
                        const SizedBox(width: 12),
                        const Icon(Icons.local_fire_department_outlined,
                            color: Colors.orangeAccent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$calories Cal',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Macronutrients row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNutrientInfo('Protein', '${protein}g', Colors.blue),
                        _buildNutrientInfo('Carbs', '${carbs}g', Colors.green),
                        _buildNutrientInfo('Fat', '${fat}g', Colors.orange),
                      ],
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

  Widget _buildNutrientInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(value,
            style: const TextStyle(
                color: Color(0xFF222222), fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB29BFF),
        title: const Text('My Meal Plans',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF8E7AFE))))
          : _mealPlans.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.no_food, size: 70, color: Color(0xFF8E7AFE)),
            SizedBox(height: 16),
            Text('No meal plans yet',
                style: TextStyle(color: Colors.white, fontSize: 18)),
            SizedBox(height: 8),
            Text(
                "Your trainer hasn't assigned any meal plans yet",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mealPlans.length,
        itemBuilder: (context, index) =>
            _buildMealCard(_mealPlans[index], index),
      ),
    );
  }
}
