import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  Future<DocumentSnapshot> _getUserData() async {
    return await FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Page")),
      body: FutureBuilder<DocumentSnapshot>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User data not found.'));
          }

          var userData = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('First Name: ${userData['firstName']}'),
                Text('Middle Name: ${userData['middleName']}'),
                Text('Last Name: ${userData['lastName']}'),
                Text('Email: ${userData['email']}'),
                Text('Phone: ${userData['phone']}'),
                Text('Date of Birth: ${userData['dob']}'),
                Text('Role: ${userData['role']}'),
                Text('Coach: ${userData['coach']}'),
                Text('Diseases: ${userData['diseases'].join(', ')}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
