import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({required this.userId, Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  Map<String, dynamic> userData = {};
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "User not found";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching profile: $e";
        _isLoading = false;
      });
    }
  }

  String _calculateAge() {
    if (userData['dob'] == null) return "N/A";

    try {
      // Parse DOB using the format from Firestore
      List<String> parts = userData['dob'].split('-');
      if (parts.length != 3) return "N/A";

      DateTime birthDate = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2])
      );

      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;

      // Adjust age if birthday hasn't occurred yet this year
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }

      return "$age";
    } catch (e) {
      return "N/A";
    }
  }

  String _formatDOB() {
    if (userData['dob'] == null) return "N/A";

    try {
      // Convert from YYYY-MM-DD to DD / MM / YYYY format
      List<String> parts = userData['dob'].split('-');
      if (parts.length != 3) return userData['dob'];

      return "${parts[2]} / ${parts[1]} / ${parts[0]}";
    } catch (e) {
      return userData['dob'];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        appBar: AppBar(
          title: const Text("My Profile", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF6A48F6),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF6A48F6)),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        appBar: AppBar(
          title: const Text("My Profile", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF6A48F6),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    String weightDisplay = "${userData['weight'] ?? '75'} ${userData['weightUnit'] ?? 'Kg'}";
    String heightDisplay = "${userData['height'] ?? '1.65'} ${userData['heightUnit'] ?? 'CM'}";

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("My Profile",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500
            )
        ),
        backgroundColor: const Color(0xFF6A48F6),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: const Color(0xFF6A48F6),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage('assets/profile.png'),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2DC30),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.camera_alt, size: 16, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userData['firstName'] != null ?
                    '${userData['firstName']} ${userData['lastName'] ?? ''}' :
                    'Madison Smith',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData['email'] ?? 'madisons@example.com',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Birthday: ${_formatDOB()}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildProfileStat(weightDisplay, 'Weight'),
                        _buildProfileStat('${_calculateAge()} Years Old', 'Age'),
                        _buildProfileStat(heightDisplay, 'Height'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Full name',
                style: TextStyle(color: Color(0xFF9D7BFF), fontSize: 14),
              ),
            ),
            _buildTextField(userData['firstName'] != null ?
            '${userData['firstName']} ${userData['lastName'] ?? ''}' :
            'Madison Smith'),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Email',
                style: TextStyle(color: Color(0xFF9D7BFF), fontSize: 14),
              ),
            ),
            _buildTextField(userData['email'] ?? 'madisons@example.com'),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Mobile Number',
                style: TextStyle(color: Color(0xFF9D7BFF), fontSize: 14),
              ),
            ),
            _buildTextField(userData['phone'] ?? '+123 567 89000'),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Date of birth',
                style: TextStyle(color: Color(0xFF9D7BFF), fontSize: 14),
              ),
            ),
            _buildTextField(_formatDOB()),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Weight',
                style: TextStyle(color: Color(0xFF9D7BFF), fontSize: 14),
              ),
            ),
            _buildTextField(weightDisplay),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Height',
                style: TextStyle(color: Color(0xFF9D7BFF), fontSize: 14),
              ),
            ),
            _buildTextField(heightDisplay),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF9D7BFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 12
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          value,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}