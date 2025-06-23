import 'package:flutter/material.dart';
import 'package:untitled/AI/chatbot.dart';
import 'package:untitled/Home__Page/00_home_page.dart';
import 'package:untitled/Home__Page/favorite_page.dart';
import 'package:untitled/Profile/Notifications_Settings_Page.dart';
import 'package:untitled/Profile/change_password.dart';
import 'package:untitled/Profile/profile.dart';
import 'package:untitled/Home__Page/favorite_page.dart';
import 'package:untitled/AI/chatbot.dart';
import 'package:untitled/Home__Page/00_home_page.dart';

class SettingsPage extends StatefulWidget {
  final String userId;

  const SettingsPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _currentNavIndex = 3;

  void _onNavTapped(int index) {
    if (index == _currentNavIndex) return;

    setState(() => _currentNavIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => FavoritesPage(favoriteRecipes: [])),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChatPage()),
        );
        break;
      case 3:
      // already in settings
        break;
    }
  }

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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ProfilePage(userId: widget.userId),
              ),
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
                  MaterialPageRoute(
                      builder: (_) => const NotificationSettingsPage()),
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
                  MaterialPageRoute(
                      builder: (_) => const PasswordSettingsPage()),
                );
              },
            ),
            buildSettingTile(
              context,
              icon: Icons.person,
              title: "Delete Account",
              onTap: () {
                // لسه هتتظبط
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFB29BFF),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: _onNavTapped,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          iconSize: 28,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ImageIcon(AssetImage('assets/icons/home.png')),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ImageIcon(AssetImage('assets/icons/fav.png')),
              ),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ImageIcon(AssetImage('assets/icons/chat.png')),
              ),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ImageIcon(AssetImage('assets/icons/User.png')),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSettingTile(BuildContext context,
      {required IconData icon,
        required String title,
        required VoidCallback onTap}) {
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
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.yellow),
          onTap: onTap,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}