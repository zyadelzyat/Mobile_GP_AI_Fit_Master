import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/AI/chatbot.dart';
import 'package:untitled/profile.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:untitled/theme_provider.dart'; // Import your ThemeProvider
import 'package:untitled/videos_page.dart'; // Import the new VideosPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavIndex = 0;
  int _selectedCategoryIndex = 0;

  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    _youtubeController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(
        "https://www.youtube.com/shorts/ijkt_wsg_Jo",
      )!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          "Hi, User",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).primaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Theme.of(context).primaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person, color: Theme.of(context).primaryColor), // Profile Icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage(userId: '',)),
              );
            },
          ),
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "It's time to challenge your limits.",
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCategoryIcon(Icons.fitness_center, "Workout", 0),
                  _buildCategoryIcon(Icons.insert_chart, "Progress", 1),
                  _buildCategoryIcon(Icons.restaurant, "Nutrition", 2),
                  _buildCategoryIcon(Icons.chat, "Chat Bot", 3),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                "Recommendations",
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              _buildVideoRecommendationCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).bottomAppBarTheme.color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _selectedNavIndex,
            onTap: (index) {
              setState(() {
                _selectedNavIndex = index;
              });
              // Navigate to the corresponding page
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VideosPage()),
                );
              }
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFFE2F163),
            unselectedItemColor: const Color(0xFFB3A0FF),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: _buildAnimatedNavIcon(Icons.home, 0),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _buildAnimatedNavIcon(Icons.video_library, 1),
                label: 'Videos',
              ),
              BottomNavigationBarItem(
                icon: _buildAnimatedNavIcon(Icons.fitness_center, 2),
                label: 'Workout',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label, int index) {
    bool isSelected = _selectedCategoryIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
        // Navigate to ChatPage when the Chat Bot icon is pressed
        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatPage()),
          );
        }
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isSelected ? 60 : 50,
            height: isSelected ? 60 : 50,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE2F163) // Selected state color
                  : const Color(0xFFB3A0FF), // Default state color
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFE2F163) : const Color(0xFFB3A0FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedNavIcon(IconData icon, int index) {
    bool isSelected = _selectedNavIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isSelected ? 30 : 24,
      height: isSelected ? 30 : 24,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE2F163) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.black : const Color(0xFFB3A0FF),
        size: isSelected ? 24 : 20,
      ),
    );
  }

  Widget _buildVideoRecommendationCard() {
    return Card(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recommended Video",
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16),
            ),
            const SizedBox(height: 10),
            YoutubePlayer(
              controller: _youtubeController,
              showVideoProgressIndicator: true,
            ),
          ],
        ),
      ),
    );
  }
}