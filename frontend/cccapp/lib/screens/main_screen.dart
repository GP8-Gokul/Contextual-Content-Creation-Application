import 'dart:developer';
import 'package:cccapp/service/auth/logout.dart';
import 'package:cccapp/widgets/bg.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static String routeName = 'main_screen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const Color primaryPurple = Color(0xFF9C27B0);
  static const Color darkPurple = Color(0xFF6A1B9A);
  static const Color lightPurple = Color(0xFFE1BEE7);
  static const Color backgroundMid = Colors.grey;

  String _selectedStudyPlan = 'STUDY PLAN 1';
  List<String> _studyPlans = ['STUDY PLAN 1', 'STUDY PLAN 2', 'STUDY PLAN 3'];

  int? _selectedTileIndex;
  List<TopicData> _topicData = [];

  @override
  void initState() {
    super.initState();
    _generateSampleData();
  }

  void _generateSampleData() {
    final now = DateTime.now();

    _topicData.add(TopicData(
        date: DateTime(now.year, 2, 28),
        topics: [
          "Introduction to Algorithms",
          "Basic Data Structures",
          "Time Complexity Analysis"
        ],
        isLocked: false));

    // March 1
    _topicData.add(TopicData(
        date: DateTime(now.year, 3, 1),
        topics: [
          "Sorting Algorithms",
          "Searching Techniques",
          "Recursion Basics"
        ],
        isLocked: false));

    _topicData.add(TopicData(
        date: DateTime(now.year, 3, 2),
        topics: [
          "Dynamic Programming",
          "Greedy Algorithms",
          "Divide and Conquer"
        ],
        isLocked: false));

    _topicData.add(TopicData(
        date: DateTime(now.year, 3, 3),
        topics: [
          "Graph Theory Basics",
          "Tree Data Structures",
          "Heap and Priority Queue"
        ],
        isLocked: false));

    _topicData.add(TopicData(
        date: DateTime(now.year, 3, 4),
        topics: [
          "Advanced Graph Algorithms",
          "Shortest Path Problems",
          "Minimum Spanning Tree"
        ],
        isLocked: true));

    _topicData.add(TopicData(
        date: DateTime(now.year, 3, 5),
        topics: ["String Algorithms", "Pattern Matching", "Text Processing"],
        isLocked: true));
  }

  bool _isAccessible(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final topicDate = DateTime(date.year, date.month, date.day);
    return !topicDate.isAfter(today);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              logoutUser();
              Navigator.of(context).pop('login_screen');
            }
            if (value == 'storage') {
              Navigator.of(context).pushNamed('storage_screen');
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: const [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: const [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'storage',
              child: Row(
                children: const [
                  Icon(Icons.storage),
                  SizedBox(width: 8),
                  Text('Storage'),
                ],
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: darkPurple,
        centerTitle: true,
        title: const Text(
          'MAIN SCREEN',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Stack(
        children: [
          GradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildGradientButton(
                          title: 'CONTENT\nCREATION',
                          onTap: () {
                            log('Content Creation button pressed');
                            Navigator.of(context).pushNamed('input_screen');
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGradientButton(
                          title: 'STUDY PLAN\nCREATION',
                          onTap: () {
                            log('Study Plan Creation button pressed');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: darkPurple.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: primaryPurple,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedStudyPlan,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                DropdownButton<String>(
                                  value: _selectedStudyPlan,
                                  dropdownColor: Colors.grey.shade700,
                                  underline: Container(),
                                  style: const TextStyle(color: Colors.white),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedStudyPlan = newValue;
                                      });
                                    }
                                  },
                                  items: _studyPlans
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _topicData.length,
                              itemBuilder: (context, index) {
                                final topic = _topicData[index];
                                final isAccessible = _isAccessible(topic.date);

                                return Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (isAccessible) {
                                          setState(() {
                                            _selectedTileIndex =
                                                _selectedTileIndex == index
                                                    ? null
                                                    : index;
                                          });

                                          if (_selectedTileIndex == index) {
                                            _showTopicDetail(context, topic);
                                          }
                                        }
                                      },
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade500,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              DateFormat('MMM d')
                                                  .format(topic.date)
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Icon(
                                              isAccessible
                                                  ? Icons.lock_open
                                                  : Icons.lock,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 2,
                    child: _buildScrollableArea(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTopicDetail(BuildContext context, TopicData topic) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundMid.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryPurple.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM d, yyyy').format(topic.date),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(color: primaryPurple, thickness: 1),
                const SizedBox(height: 16),
                const Text(
                  "Today's Topics:",
                  style: TextStyle(
                    color: lightPurple,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...topic.topics
                    .map((topicName) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 10,
                                color: primaryPurple,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  topicName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Start Studying'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientButton(
      {required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [darkPurple, primaryPurple],
            stops: [0.3, 1.0],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: darkPurple.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableArea() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Words for today',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // This area will be filled with future content
                    Text(
                      'Future content will appear here with texts and checkboxes.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Data class for topics
class TopicData {
  final DateTime date;
  final List<String> topics;
  final bool isLocked;

  TopicData({
    required this.date,
    required this.topics,
    required this.isLocked,
  });
}
