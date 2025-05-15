import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:untitled/Login___Signup/01_signin_screen.dart';
import 'detailed_profile_page.dart';
import 'package:untitled/AI/chatbot.dart';
import '../Home__Page/favorite_page.dart';
import '../rating/trainer_ratings_page.dart';
import '../Home__Page/trainer_trainees_page.dart';
import '../Home__Page/00_home_page.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({required this.userId, super.key});

  @override
  State createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  Map userData = {};
  String? errorMessage;

  // Membership plans
  final List<Map<String, dynamic>> _membershipPlans = [
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
    if (userData['dob'] == null ||
        (userData['dob'] is String && (userData['dob'] as String).isEmpty)) return "N/A";

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
          } catch (_) {
            return "N/A";
          }
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
    if (userData['dob'] == null ||
        (userData['dob'] is String && (userData['dob'] as String).isEmpty)) return "N/A";

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
          } catch (_) {
            return "N/A";
          }
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
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
                        child: const Text('Cancel', style: TextStyle(fontSize: 16)),
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
                                    (route) => false,
                              );
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
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
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
    String userRole = userData['role'] as String? ?? '';

    if (userRole == 'Trainer') {
      return Column(
        children: [
          _buildProfileMenuItem(
            icon: Icons.star_rate_outlined,
            title: 'My Ratings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrainerRatingsPage()),
              );
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.group,
            title: 'View My Trainees',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrainerTraineesPage()),
              );
            },
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  void _showMembershipDialog() {
    String userRole = userData['role'] as String? ?? '';

    // Show membership plans dialog for all users
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedPlanKey;
        Map<String, dynamic>? selectedPlanDetails;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2A2A2A),
              title: const Text('Select Membership Plan',
                  style: TextStyle(color: Color(0xFFB29BFF))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: _membershipPlans.map((plan) {
                  return RadioListTile<String>(
                    title: Text('${plan['name']} - \$${plan['price'].toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white)),
                    value: plan['typeKey'] as String,
                    groupValue: selectedPlanKey,
                    onChanged: (String? value) {
                      setDialogState(() {
                        selectedPlanKey = value;
                        selectedPlanDetails = plan;
                      });
                    },
                    activeColor: const Color(0xFFB29BFF),
                    controlAffinity: ListTileControlAffinity.trailing,
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFFB29BFF))),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB29BFF)),
                  child: const Text('Next', style: TextStyle(color: Colors.white)),
                  onPressed: selectedPlanKey == null ? null : () {
                    Navigator.of(context).pop();

                    // For Self Trainee, skip payment method selection and go directly to cash payment
                    if (userRole == 'Self Trainee') {
                      _showCashPaymentDialog(selectedPlanDetails!);
                    } else {
                      // For other roles, show payment method options
                      _showPaymentMethodDialog(selectedPlanDetails!);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCashPaymentDialog(Map<String, dynamic> planDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: Text('Confirm Cash Payment for ${planDetails['name']}',
              style: const TextStyle(color: Color(0xFFB29BFF))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You will pay \$${planDetails['price'].toStringAsFixed(2)} in cash. Your membership will be pending until payment is confirmed.',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Icon(
                Icons.money,
                color: Color(0xFFB29BFF),
                size: 48,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Color(0xFFB29BFF))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB29BFF)),
              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
                _handleCashPayment(planDetails);
              },
            ),
          ],
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
          title: Text('Select Payment Method for ${planDetails['name']}',
              style: const TextStyle(color: Color(0xFFB29BFF))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.money, color: Color(0xFFB29BFF)),
                title: const Text('Cash', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _showCashPaymentDialog(planDetails);
                },
              ),
              // Other payment methods would go here for regular users
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Color(0xFFB29BFF))),
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
      // Calculate membership dates
      DateTime now = DateTime.now();
      DateTime endDate = planDetails['typeKey'] == 'premium'
          ? now.add(const Duration(days: 365)) // 1 year for premium
          : now.add(const Duration(days: 30)); // 1 month for standard

      // Format dates for Firestore
      String startDateFormatted = DateFormat('dd / MM / yyyy').format(now);
      String endDateFormatted = DateFormat('dd / MM / yyyy').format(endDate);

      await _firestore.collection('users').doc(currentUser.uid).update({
        'membershipType': planDetails['typeKey'],
        'membershipPrice': '\$${planDetails['price'].toStringAsFixed(2)}',
        'paymentType': 'cash',
        'membershipStart': startDateFormatted,
        'membershipEnd': endDateFormatted,
        'membershipStatus': 'pending_approval',
        'membershipUpdatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cash payment request submitted. Admin will review.'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh user data to show updated membership status
      _fetchUserData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process cash payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
              );
            },
          ),
          centerTitle: true,
        ),
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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
              );
            },
          ),
          centerTitle: true,
        ),
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
    String userRole = userData['role'] as String? ?? '';
    String membershipStatus = userData['membershipStatus'] as String? ?? 'none';
    String membershipTitle = (membershipStatus == 'active' || membershipStatus == 'pending_approval')
        ? 'View Membership'
        : 'Join Membership';

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB29BFF),
        elevation: 0,
        title: const Text("My Profile",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
            );
          },
        ),
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
                      : const AssetImage('assets/profile.png') as ImageProvider,
                  backgroundColor: Colors.grey[300],
                ),
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
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text('Birthday: $birthdayDisplay',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text('Membership: ${userData['membershipType'] ?? 'None'} (${userData['membershipStatus'] ?? 'N/A'})',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
                              DetailedProfilePage(userData: Map.from(userData))),
                    );
                  },
                ),
                // Show membership option only for Trainee, not for Self Trainee
                if (userRole == 'Trainee')
                  _buildProfileMenuItem(
                    icon: Icons.card_membership,
                    title: membershipTitle,
                    onTap: _showMembershipDialog,
                  ),
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
                                FavoritesPage(favoriteRecipes: [])),
                      );
                    } catch (e) {
                      print("Error navigating to Favorites: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Could not open Favorites. Check class name."),
                              backgroundColor: Colors.red));
                    }
                  },
                ),
                // Rest of the menu items remain unchanged
                _buildProfileMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    print("Navigate to Settings");
                  },
                ),
                _buildProfileMenuItem(
                  icon: Icons.support_agent_outlined,
                  title: 'Chatbot',
                  onTap: () {
                    try {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChatPage()),
                      );
                    } catch (e) {
                      print("Error navigating to Chatbot: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Could not open Chatbot. Check class name."),
                              backgroundColor: Colors.red));
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
