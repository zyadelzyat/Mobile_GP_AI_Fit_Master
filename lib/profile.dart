import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Import your login screen
import 'Login___Signup/01_signin_screen.dart'; // Update this path to match your project structure

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({required this.userId, super.key});

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
    if (userData['dob'] == null) return "01 / 04 / 199X";

    try {
      // Convert from YYYY-MM-DD to DD / MM / YYYY format
      List<String> parts = userData['dob'].split('-');
      if (parts.length != 3) return userData['dob'];

      return "${parts[2]} / ${parts[1]} / ${parts[0]}";
    } catch (e) {
      return userData['dob'];
    }
  }

  Widget _showMembershipModal() {
    return AlertDialog(
      backgroundColor: const Color(0xFF232323),
      title: const Text(
        "Membership Details",
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMembershipDetail("Type", userData['membershipType'] ?? "Premium"),
          _buildMembershipDetail("Price", userData['membershipPrice'] ?? "\$19.99/month"),
          _buildMembershipDetail("Start Date", userData['membershipStart'] ?? "01/01/2025"),
          _buildMembershipDetail("End Date", userData['membershipEnd'] ?? "01/01/2026"),
        ],
      ),
      actions: [
        TextButton(
          child: const Text(
            "Close",
            style: TextStyle(color: Color(0xFF6A48F6)),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFFB29BFF), // Light purple background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Are you sure you want to log out?',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cancel button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6A48F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Logout button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            // Close the dialog
                            Navigator.of(context).pop();

                            // Show loading indicator
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const Dialog(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF6A48F6),
                                    ),
                                  ),
                                );
                              },
                            );

                            // Sign out from Firebase Auth
                            await FirebaseAuth.instance.signOut();

                            // Close loading indicator
                            Navigator.of(context).pop();

                            // Navigate to SignInScreen and clear navigation stack
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const SignInScreen(),
                              ),
                                  (route) => false,
                            );
                          } catch (e) {
                            // Close loading indicator if still showing
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }

                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Logout failed: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDFF233), // Yellow-green color
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Yes, logout',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMembershipDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
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
    String ageDisplay = "${_calculateAge()} Years Old";

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
            // Purple header section
            Container(
              color: const Color(0xFF6A48F6),
              width: double.infinity,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Profile image with camera icon
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
                  // User name
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
                  // Email
                  Text(
                    userData['email'] ?? 'madisons@example.com',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  // Birthday
                  Text(
                    'Birthday: ${_formatDOB()}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  // Stats row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildProfileStat(weightDisplay, 'Weight'),
                        _buildProfileStat(ageDisplay, 'Age'),
                        _buildProfileStat(heightDisplay, 'Height'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Profile fields
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

            // New fields
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Gender',
                style: TextStyle(color: Color(0xFF9D7BFF), fontSize: 14),
              ),
            ),
            _buildTextField(userData['gender'] ?? 'Female'),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Diseases',
                style: TextStyle(color: Color(0xFF9D7BFF), fontSize: 14),
              ),
            ),
            _buildTextField(userData['Diseases'] ?? 'None'),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Role',
                style: TextStyle(color: Color(0xFF9D7BFF), fontSize: 14),
              ),
            ),
            _buildTextField(userData['role'] ?? 'Member'),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Coach',
                style: TextStyle(color: Color(0xFF9D7BFF), fontSize: 14),
              ),
            ),
            _buildTextField(userData['coach'] ?? 'Not assigned'),

            // Membership button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => _showMembershipModal(),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A48F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "View Membership Details",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // Logout button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: () {
                  _showLogoutDialog();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF232323),
                    border: Border.all(color: const Color(0xFF6A48F6)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      color: Color(0xFF6A48F6),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Profile tab
        backgroundColor: const Color(0xFF232323),
        selectedItemColor: const Color(0xFF6A48F6),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index != 2) {
            Navigator.pop(context);
          }
        },
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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.transparent),
        ),
        child: Text(
          value,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}