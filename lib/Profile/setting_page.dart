import 'package:flutter/material.dart';
import 'package:untitled/Profile/Notifications_Settings_Page.dart';
import 'package:untitled/Profile/change_password.dart';
import 'package:untitled/Profile/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  final String userId;

  const SettingsPage({super.key, required this.userId});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.yellow),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(userId: userId)), // ✅
            );
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF896CFE),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          children: [
            buildSettingTile(
              context,
              icon: Icons.notifications,
              title: "Notification Setting",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationSettingsPage()),
                );
              },
            ),
            buildSettingTile(
              context,
              icon: Icons.vpn_key,
              title: "Password Setting",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PasswordSettingsPage()),
                );
              },
            ),
            buildSettingTile(
              context,
              icon: Icons.person,
              title: "Delete Account",
              onTap: () {
                // Add navigation when implemented
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF896CFE),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Support'),
        ],
      ),
    );
  }

  Widget buildSettingTile(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF896CFE),
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          trailing: const Icon(Icons.arrow_drop_down, color: Colors.yellow),
          onTap: onTap,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
