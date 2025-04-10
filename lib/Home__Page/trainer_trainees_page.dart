import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrainerTraineesPage extends StatelessWidget {
  const TrainerTraineesPage({super.key});

  Future<List<Map<String, dynamic>>> fetchTrainees() async {
    User? trainer = FirebaseAuth.instance.currentUser;
    if (trainer == null) return [];

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('coachId', isEqualTo: trainer.uid)
        .where('role', isEqualTo: 'Trainee') // optional filter
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trainees'),
        backgroundColor: const Color(0xFF8E7AFE),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchTrainees(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final trainees = snapshot.data ?? [];

          if (trainees.isEmpty) {
            return const Center(child: Text("No trainees assigned yet."));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Phone')),
                DataColumn(label: Text('Disease')),
              ],
              rows: trainees.map((trainee) {
                final name = "${trainee['firstName'] ?? ''} ${trainee['lastName'] ?? ''}";
                return DataRow(cells: [
                  DataCell(Text(name)),
                  DataCell(Text(trainee['email'] ?? '')),
                  DataCell(Text(trainee['phone'] ?? '')),
                  DataCell(Text(trainee['disease'] ?? '')),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
