import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: NotificationSettingsPage(),
  ));
}

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // States for switches
  bool generalNotification = true;
  bool sound = true;
  bool doNotDisturb = true;
  bool vibrate = true;
  bool lockScreen = true;
  bool reminders = true;
  bool lightMood = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.yellow),
          onPressed: () => Navigator.pop(context), // ✅ تم التعديل هنا فقط
        ),
        title: const Text(
          'Notifications Settings',
          style: TextStyle(
            color: Color(0xFF896CFE),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        children: [
          buildSwitchTile("General Notification", generalNotification, (val) {
            setState(() => generalNotification = val);
          }),
          buildSwitchTile("Sound", sound, (val) {
            setState(() => sound = val);
          }),
          buildSwitchTile("Don’t Disturb Mode", doNotDisturb, (val) {
            setState(() => doNotDisturb = val);
          }),
          buildSwitchTile("Vibrate", vibrate, (val) {
            setState(() => vibrate = val);
          }),
          buildSwitchTile("Lock Screen", lockScreen, (val) {
            setState(() => lockScreen = val);
          }),
          buildSwitchTile("Reminders", reminders, (val) {
            setState(() => reminders = val);
          }),
          buildSwitchTile("Light mood", lightMood, (val) {
            setState(() => lightMood = val);
          }),
        ],
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

  Widget buildSwitchTile(String title, bool value, Function(bool) onChanged, {bool isYellow = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: isYellow ? Colors.yellow : const Color(0xFF896CFE),
          ),
        ],
      ),
    );
  }
}
