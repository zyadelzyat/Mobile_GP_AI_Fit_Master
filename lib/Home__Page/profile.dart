// [File: profile.dart]
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting

// Import your login screen (ensure the path is correct)
import 'package:untitled/Login___Signup/01_signin_screen.dart'; // Replace 'untitled' with your project name

// Import the detailed profile page
import 'detailed_profile_page.dart'; // Make sure this path is correct

// Import for Chatbot - Check path and project name 'untitled'
import 'package:untitled/AI/chatbot.dart'; // Replace 'untitled' if needed.

// Import Favorite Page - Make sure this path is correct
import 'favorite_page.dart'; // Ensure 'FavoritePage' is defined.

// Import TrainerRatingsPage
import 'trainer_ratings_page.dart'; // Add this import for the trainer ratings page

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({required this.userId, super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Added FirebaseAuth instance
  bool _isLoading = true;
  Map<String, dynamic> userData = {};
  String? errorMessage;

  // Define membership plans (name, price, typeKey for Firestore)
  final List<Map<String, dynamic>> _membershipPlans = [
    {'name': 'Basic Plan', 'price': 20.0, 'typeKey': 'basic'},
    {'name': 'Standard Plan', 'price': 30.0, 'typeKey': 'standard'},
    {'name': 'Premium Plan', 'price': 50.0, 'typeKey': 'premium'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      errorMessage = null;
    });
    try {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(widget.userId).get();
      if (userDoc.exists) {
        if (!mounted) return;
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;
          // Add userId to the map to pass it easily
          userData['userId'] = widget.userId;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage = "User not found";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Error fetching profile: $e";
        _isLoading = false;
      });
    }
  }

  String _calculateAge() {
    if (userData['dob'] == null || (userData['dob'] is String && (userData['dob'] as String).isEmpty)) return "N/A";
    DateTime? birthDate;
    if (userData['dob'] is Timestamp) {
      birthDate = (userData['dob'] as Timestamp).toDate();
    } else if (userData['dob'] is String) {
      try {
        birthDate = DateTime.parse(userData['dob'] as String);
      } catch (e) {
        List<String> parts = (userData['dob'] as String).split('-');
        if (parts.length == 3) {
          try {
            birthDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          } catch (_) { return "N/A"; }
        } else {
          return "N/A";
        }
      }
    } else {
      return "N/A";
    }

    if (birthDate == null) return "N/A";
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return "$age";
  }

  String _formatBirthday() {
    if (userData['dob'] == null || (userData['dob'] is String && (userData['dob'] as String).isEmpty)) return "N/A";
    DateTime? birthDate;
    if (userData['dob'] is Timestamp) {
      birthDate = (userData['dob'] as Timestamp).toDate();
    } else if (userData['dob'] is String) {
      try {
        birthDate = DateTime.parse(userData['dob'] as String);
      } catch (e) {
        List<String> parts = (userData['dob'] as String).split('-');
        if (parts.length == 3) {
          try {
            birthDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          } catch (_) { return "N/A"; }
        } else {
          return "N/A";
        }
      }
    } else {
      return "N/A";
    }

    if (birthDate == null) return "N/A";
    String day = DateFormat('d').format(birthDate);
    String suffix = 'th';
    if (day.endsWith('1') && !day.endsWith('11')) suffix = 'st';
    else if (day.endsWith('2') && !day.endsWith('12')) suffix = 'nd';
    else if (day.endsWith('3') && !day.endsWith('13')) suffix = 'rd';
    return "${DateFormat('MMMM').format(birthDate)} $day$suffix";
  }

  void _showLogoutDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFFB29BFF),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Are you sure you want to log out?',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6A48F6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(vertical: 12)),
                        child:
                        const Text('Cancel', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop(); // Close confirmation dialog
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) => const Dialog(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(
                                              Color(0xFF9D7BFF))))));
                          try {
                            await _auth.signOut();
                            if (mounted) Navigator.of(context).pop(); // Pop loading indicator
                            if (mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => const SignInScreen()),
                                      (route) => false);
                            }
                          } catch (e) {
                            if (mounted) Navigator.of(context).pop(); // Pop loading indicator
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('Logout failed: ${e.toString()}'),
                                  backgroundColor: Colors.red));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDFF233),
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(vertical: 12)),
                        child: const Text('Yes, logout',
                            style: TextStyle(fontSize: 16)),
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

  Widget _buildStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildProfileMenuItem(
      {required IconData icon,
        required String title,
        required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Color(0xFFB29BFF), shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 20)),
            const SizedBox(width: 20),
            Expanded(
                child: Text(title,
                    style: const TextStyle(color: Colors.white, fontSize: 16))),
            const Icon(Icons.chevron_right,
                color: Color(0xFFE2DC30), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSpecificMenuItems() {
    if (userData['role'] == 'Trainer') {
      return _buildProfileMenuItem(
        icon: Icons.star_rate_outlined,
        title: 'My Ratings',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TrainerRatingsPage()),
          );
        },
      );
    }
    return const SizedBox.shrink(); // Return empty widget if not a trainer
  }

  void _showMembershipDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedPlanKey; // To hold the key of the selected plan
        Map<String, dynamic>? selectedPlanDetails;
        return StatefulBuilder( // Use StatefulBuilder for dialog state
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2A2A2A), // Dark background
              title: Text('Select Membership Plan', style: TextStyle(color: Color(0xFFB29BFF))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: _membershipPlans.map((plan) {
                  return RadioListTile<String>(
                    title: Text('${plan['name']} - \$${plan['price'].toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                    value: plan['typeKey'] as String,
                    groupValue: selectedPlanKey,
                    onChanged: (String? value) {
                      setDialogState(() {
                        selectedPlanKey = value;
                        selectedPlanDetails = plan;
                      });
                    },
                    activeColor: Color(0xFFB29BFF),
                    controlAffinity: ListTileControlAffinity.trailing,
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Color(0xFFB29BFF))),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFB29BFF)),
                  child: Text('Next', style: TextStyle(color: Colors.white)),
                  onPressed: selectedPlanKey == null ? null : () {
                    Navigator.of(context).pop(); // Close plan selection dialog
                    _showPaymentMethodDialog(selectedPlanDetails!);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPaymentMethodDialog(Map<String, dynamic> planDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: Text('Choose Payment Method for ${planDetails['name']}', style: TextStyle(color: Color(0xFFB29BFF))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.money, color: Color(0xFFB29BFF)),
                title: Text('Pay with Cash', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop(); // Close payment method dialog
                  _handleCashPayment(planDetails);
                },
              ),
              ListTile(
                leading: Icon(Icons.credit_card, color: Color(0xFFB29BFF)),
                title: Text('Pay with Visa', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop(); // Close payment method dialog
                  _handleVisaPayment(planDetails);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Color(0xFFB29BFF))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleCashPayment(Map<String, dynamic> planDetails) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be logged in.')));
      return;
    }

    try {
      await _firestore.collection('users').doc(currentUser.uid).update({
        'membershipType': planDetails['typeKey'],
        'membershipPrice': planDetails['price'],
        'membershipPaymentType': 'cash',
        'membershipStatus': 'pending_approval', // Admin needs to approve
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cash payment request submitted. Admin will review.')),
      );
      _fetchUserData(); // Refresh user data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process cash payment: $e')),
      );
    }
  }

  void _handleVisaPayment(Map<String, dynamic> planDetails) {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be logged in.')));
      return;
    }
    // Placeholder for Visa payment integration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Initiating Visa payment for ${planDetails['name']}. Integration with a payment gateway is required here.')),
    );
    print("Visa payment for ${planDetails['typeKey']} selected. Implement payment gateway.");
    // After successful payment via a gateway, you would update Firestore:
    // await _firestore.collection('users').doc(currentUser.uid).update({
    //   'membershipType': planDetails['typeKey'],
    //   'membershipPrice': planDetails['price'],
    //   'membershipPaymentType': 'visa',
    //   'membershipStatus': 'active',
    //   'paymentIntentId': 'your_payment_intent_id_from_gateway', // Optional
    //   'updatedAt': FieldValue.serverTimestamp(),
    // });
    // _fetchUserData(); // Refresh user data
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        appBar: AppBar(
            backgroundColor: const Color(0xFFB29BFF),
            elevation: 0,
            title: const Text("My Profile",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500)),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop()),
            centerTitle: true),
        body: const Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF9D7BFF)))),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        appBar: AppBar(
            backgroundColor: const Color(0xFFB29BFF),
            elevation: 0,
            title: const Text("My Profile",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500)),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop()),
            centerTitle: true),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center))),
      );
    }

    String weightDisplay =
        "${userData['weight'] ?? 'N/A'} ${userData['weightUnit'] ?? 'Kg'}";
    String heightDisplay = userData['heightUnit'] == 'CM'
        ? "${userData['height'] ?? 'N/A'} CM"
        : "${userData['height'] ?? 'N/A'} ${userData['heightUnit'] ?? 'M'}";
    String ageDisplay = _calculateAge();
    String birthdayDisplay = _formatBirthday();

    // *** MODIFICATION START ***
    String userRole = userData['role'] as String? ?? '';
    String membershipStatus = userData['membershipStatus'] as String? ?? 'none';
    String membershipTitle = (membershipStatus == 'active' || membershipStatus == 'pending_approval')
        ? 'Manage Membership'
        : 'Join Membership';
    // *** MODIFICATION END ***

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB29BFF),
        elevation: 0,
        title: const Text("My Profile",
            style:
            TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFFB29BFF),
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                CircleAvatar(
                    radius: 45,
                    backgroundImage: userData['profileImageUrl'] != null &&
                        (userData['profileImageUrl'] as String).isNotEmpty
                        ? NetworkImage(userData['profileImageUrl'] as String)
                        : const AssetImage('assets/profile.png')
                    as ImageProvider,
                    backgroundColor: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                    userData['firstName'] != null
                        ? '${userData['firstName']} ${userData['lastName'] ?? ''}'
                        : 'User Name',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(userData['email'] ?? 'user@example.com',
                    style:
                    const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text('Birthday: $birthdayDisplay',
                    style:
                    const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text('Membership: ${userData['membershipType'] ?? 'None'} (${userData['membershipStatus'] ?? 'N/A'})',
                    style:
                    const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                      color: const Color(0xFF9D7BFF),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(weightDisplay, 'Weight'),
                      Container(height: 30, width: 1, color: Colors.white30),
                      _buildStatItem(ageDisplay, 'Years Old'),
                      Container(height: 30, width: 1, color: Colors.white30),
                      _buildStatItem(heightDisplay, 'Height'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 10.0),
              children: [
                _buildProfileMenuItem(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DetailedProfilePage(userData: Map<String, dynamic>.from(userData))),
                    );
                  },
                ),
                // *** MODIFICATION START ***
                if (userRole != 'Trainer') // Conditionally show membership item
                  _buildProfileMenuItem(
                    icon: Icons.card_membership,
                    title: membershipTitle, // Dynamic title
                    onTap: _showMembershipDialog,
                  ),
                // *** MODIFICATION END ***
                _buildRoleSpecificMenuItems(),
                _buildProfileMenuItem(
                  icon: Icons.star_outline,
                  title: 'Favorite',
                  onTap: () {
                    try {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                FavoritesPage(favoriteRecipes: [])), // Ensure FavoritesPage is correctly defined
                      );
                    } catch (e) {
                      print("Error navigating to Favorites: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Could not open Favorites. Check class name."),
                            backgroundColor: Colors.red),
                      );
                    }
                  },
                ),
                _buildProfileMenuItem(
                  icon: Icons.list_alt_outlined,
                  title: 'My Plan',
                  onTap: () {
                    print("Navigate to My Plan");
                  }, // Placeholder
                ),
                _buildProfileMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    print("Navigate to Settings");
                  }, // Placeholder
                ),
                _buildProfileMenuItem(
                  icon: Icons.support_agent_outlined,
                  title: 'Chatbot',
                  onTap: () {
                    try {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatPage(), // Ensure ChatPage is correctly defined
                        ),
                      );
                    } catch (e) {
                      print("Error navigating to Chatbot: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Could not open Chatbot. Check class name."),
                            backgroundColor: Colors.red),
                      );
                    }
                  },
                ),
                _buildProfileMenuItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: _showLogoutDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
