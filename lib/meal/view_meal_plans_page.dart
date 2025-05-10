import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_meal_plan_page.dart';

class ViewMealPlansPage extends StatefulWidget {
  final String traineeId;
  final String traineeName;

  const ViewMealPlansPage({
    Key? key,
    required this.traineeId,
    required this.traineeName,
  }) : super(key: key);

  @override
  _ViewMealPlansPageState createState() => _ViewMealPlansPageState();
}

class _ViewMealPlansPageState extends State<ViewMealPlansPage> {
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
      if (currentUser == null) return;

      QuerySnapshot mealPlansSnapshot = await _firestore
          .collection('meal_plans')
          .where('traineeId', isEqualTo: widget.traineeId)
          .where('trainerId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> mealPlans = [];
      for (var doc in mealPlansSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        mealPlans.add(data);
      }

      if (mounted) {
        setState(() {
          _mealPlans = mealPlans;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading meal plans: $e')),
        );
      }
    }
  }

  Future<void> _deleteMealPlan(String mealPlanId) async {
    try {
      await _firestore.collection('meal_plans').doc(mealPlanId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal plan deleted successfully')),
        );
        _loadMealPlans();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting meal plan: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(String mealPlanId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text('Delete Meal Plan',
              style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to delete this meal plan?',
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF8E7AFE))),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMealPlan(mealPlanId);
              },
              child: const Text('Delete',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB29BFF),
        title: Text('${widget.traineeName}\'s Meal Plans',
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E7AFE)),
        ),
      )
          : _mealPlans.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.no_food,
              size: 70,
              color: Color(0xFF8E7AFE),
            ),
            const SizedBox(height: 16),
            const Text(
              'No meal plans yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a meal plan for this trainee',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMealPlanPage(
                      traineeId: widget.traineeId,
                      traineeName: widget.traineeName,
                    ),
                  ),
                );
                if (result == true) {
                  _loadMealPlans();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Meal Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8E7AFE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mealPlans.length,
        itemBuilder: (context, index) {
          final mealPlan = _mealPlans[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: const Color(0xFF2A2A2A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8E7AFE).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          mealPlan['mealType'] ?? 'Meal',
                          style: const TextStyle(
                            color: Color(0xFF8E7AFE),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _showDeleteConfirmation(mealPlan['id']),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    mealPlan['description'] ?? 'No description',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNutrientInfo(
                        'Protein',
                        '${mealPlan['protein'] ?? 0}g',
                        Colors.blue,
                      ),
                      _buildNutrientInfo(
                        'Carbs',
                        '${mealPlan['carbs'] ?? 0}g',
                        Colors.green,
                      ),
                      _buildNutrientInfo(
                        'Fat',
                        '${mealPlan['fat'] ?? 0}g',
                        Colors.orange,
                      ),
                      _buildNutrientInfo(
                        'Calories',
                        '${mealPlan['calories'] ?? 0}',
                        Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _mealPlans.isNotEmpty
          ? FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMealPlanPage(
                traineeId: widget.traineeId,
                traineeName: widget.traineeName,
              ),
            ),
          );
          if (result == true) {
            _loadMealPlans();
          }
        },
        backgroundColor: const Color(0xFF8E7AFE),
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  Widget _buildNutrientInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
