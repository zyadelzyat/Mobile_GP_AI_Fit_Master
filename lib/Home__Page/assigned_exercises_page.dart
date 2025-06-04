import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:untitled/AI/chatbot.dart'; // For ChatPage
import '../Profile/profile.dart';
import '../Store/Store.dart'; // For SupplementsStorePage
import '00_home_page.dart';
import 'favorite_page.dart';

class AssignedExercisesPage extends StatefulWidget {
  const AssignedExercisesPage({Key? key}) : super(key: key);

  @override
  State<AssignedExercisesPage> createState() => _AssignedExercisesPageState();
}

class _AssignedExercisesPageState extends State<AssignedExercisesPage> {
  int _currentNavIndex = 0;
  bool _isRefreshing = false;
  int _selectedWeekIndex = 0; // 0: Week 1, 1: Week 2, 2: Week 3, 3: Week 4
  final List<String> _weekOptions = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];

  // Track watched videos
  final Map<String, bool> _watchedVideos = {};

  Future<List<Map<String, dynamic>>> _fetchAssignedExercises() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('assigned_exercises')
        .where('week', isEqualTo: _selectedWeekIndex + 1) // Filter by selected week
        .orderBy('muscleGroup', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> _launchVideo(BuildContext context, String exerciseId, String? videoUrl) async {
    if (videoUrl == null || videoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No video URL available')),
      );
      return;
    }

    final Uri uri = Uri.parse(videoUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Mark video as watched
        setState(() {
          _watchedVideos[exerciseId] = true;
        });

        // Update Firestore to mark as watched
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('watched_videos')
              .doc(exerciseId)
              .set({
            'watchedAt': FieldValue.serverTimestamp(),
            'videoUrl': videoUrl
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open video URL')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _toggleCompletionStatus(String exerciseId, bool currentStatus) async {
    setState(() {
      _isRefreshing = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('assigned_exercises')
          .doc(exerciseId)
          .update({
        'completed': !currentStatus,
        'completedAt': !currentStatus ? FieldValue.serverTimestamp() : null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(!currentStatus
              ? 'Exercise marked as completed!'
              : 'Exercise marked as incomplete'),
          backgroundColor: !currentStatus ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 20,
            right: 20,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _checkWatchedVideos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('watched_videos')
          .get();

      setState(() {
        for (var doc in snapshot.docs) {
          _watchedVideos[doc.id] = true;
        }
      });
    } catch (e) {
      print('Error fetching watched videos: $e');
    }
  }

  Future<void> _refreshExercises() async {
    setState(() {
      _isRefreshing = true;
    });

    await _checkWatchedVideos();
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkWatchedVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text(
          'My Workouts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF8E7AFE),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshExercises,
        color: const Color(0xFF8E7AFE),
        child: Column(
          children: [
            _buildWeekFilter(),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchAssignedExercises(),
                builder: (context, snapshot) {
                  if (_isRefreshing || snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF8E7AFE)),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  final exercises = snapshot.data!;

                  // Group exercises by muscle group
                  Map<String, List<Map<String, dynamic>>> exercisesByMuscleGroup = {};

                  for (var exercise in exercises) {
                    String muscleGroup = exercise['muscleGroup'] ?? 'Other';
                    if (!exercisesByMuscleGroup.containsKey(muscleGroup)) {
                      exercisesByMuscleGroup[muscleGroup] = [];
                    }
                    exercisesByMuscleGroup[muscleGroup]!.add(exercise);
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWeekHeader(),
                        const SizedBox(height: 20),
                        ...exercisesByMuscleGroup.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  color: Color(0xFFE2F163),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...entry.value.map((exercise) => _buildExerciseCard(exercise)).toList(),
                              const SizedBox(height: 20),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
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
          onTap: (index) {
            if (!mounted) return;
            if (index == _currentNavIndex) return;
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
                break;
              case 1:
                List<Map<String, dynamic>> favoriteWorkouts = []; // Placeholder
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritesPage(favoriteRecipes: favoriteWorkouts),
                  ),
                );
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatPage()),
                );
                break;
              case 3:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                    ),
                  ),
                );
                break;
            }
            setState(() {
              _currentNavIndex = index;
            });
          },
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fitness_center,
            size: 80,
            color: Color(0xFF8E7AFE),
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises assigned for Week ${_selectedWeekIndex + 1}',
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8E7AFE),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            _weekOptions.length,
                (index) => GestureDetector(
              onTap: () {
                setState(() {
                  _selectedWeekIndex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedWeekIndex == index
                      ? const Color(0xFFE2F163)
                      : const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _weekOptions[index],
                  style: TextStyle(
                    color: _selectedWeekIndex == index
                        ? Colors.black
                        : Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekHeader() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color(0xFF8E7AFE),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF8E7AFE),
                  const Color(0xFF8E7AFE).withOpacity(0.7),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Week ${_selectedWeekIndex + 1} Workouts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Stay consistent with your training',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    final String id = exercise['id'] ?? '';
    final String title = exercise['title'] ?? 'Exercise';
    final String description = exercise['description'] ?? '';
    final String videoUrl = exercise['videoUrl'] ?? '';
    final bool isCompleted = exercise['completed'] == true;
    final bool isWatched = _watchedVideos[id] == true;
    final String muscleGroup = exercise['muscleGroup'] ?? 'General';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withOpacity(0.5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _launchVideo(context, id, videoUrl),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8E7AFE).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  muscleGroup,
                                  style: const TextStyle(
                                    color: Color(0xFF8E7AFE),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (isWatched)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.visibility, color: Colors.green, size: 12),
                                      SizedBox(width: 4),
                                      Text(
                                        'Watched',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                        color: isCompleted ? Colors.green : Colors.grey,
                      ),
                      onPressed: () => _toggleCompletionStatus(id, isCompleted),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (videoUrl.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => _launchVideo(context, id, videoUrl),
                    icon: const Icon(Icons.play_circle_outline, size: 16),
                    label: Text(isWatched ? 'Watch Again' : 'Watch Video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8E7AFE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                else
                  const Text(
                    'No video available',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
