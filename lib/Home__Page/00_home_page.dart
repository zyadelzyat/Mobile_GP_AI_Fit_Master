import 'package:flutter/material.dart';
import 'package:untitled/AI/chatbot.dart';
import 'package:untitled/profile.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// import 'profile.dart'; // Import the profile page

class HomePage extends StatefulWidget {
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
      flags: YoutubePlayerFlags(
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
    return Scaffold(
      backgroundColor: Color(0xFF232323),
      appBar: AppBar(
        backgroundColor: Color(0xFF232323),
        elevation: 0,
        title: Text(
          "Hi, User",
          style: TextStyle(
            color: Color(0xFF896CFE),
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Color(0xFF896CFE)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Color(0xFF896CFE)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person, color: Color(0xFF896CFE)), // Profile Icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(userId: '',)),
              );
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
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCategoryIcon(Icons.fitness_center, "Workout", 0),
                  _buildCategoryIcon(Icons.insert_chart, "Progress", 1),
                  _buildCategoryIcon(Icons.restaurant, "Nutrition", 2),
                  _buildCategoryIcon(Icons.chat, "Chat Bot", 3),
                ],
              ),
              SizedBox(height: 30),
              Text(
                "Recommendations",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 10),
              SizedBox(height: 20),
              _buildVideoRecommendationCard(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF4E4E4E),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex:
            _selectedNavIndex, // This only tracks bottom nav state
            onTap: (index) {
              setState(() {
                _selectedNavIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Color(0xFFE2F163),
            unselectedItemColor: Color(0xFFB3A0FF),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.insert_chart),
                label: 'Videos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star),
                label: 'Favourite',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Community',
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
            MaterialPageRoute(builder: (context) => ChatPage()),
          );
        }
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isSelected ? 60 : 50,
            height: isSelected ? 60 : 50,
            decoration: BoxDecoration(
              color: isSelected
                  ? Color(0xFFE2F163) // Selected state color
                  : Color(0xFFB3A0FF), // Default state color
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Color(0xFFE2F163) : Color(0xFFB3A0FF),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildVideoRecommendationCard() {
    return Card(
      color: Color(0xFF4E4E4E),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recommended Video",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 10),
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
