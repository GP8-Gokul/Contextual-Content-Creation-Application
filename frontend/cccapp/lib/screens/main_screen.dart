import 'dart:developer';
import 'package:cccapp/service/auth/logout.dart';
import 'package:cccapp/widgets/bg.dart';
import 'package:firebase_database/firebase_database.dart';
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
  static const Color softPurple = Color(0xFFE6E0F8);

  List<String> _studyPlans = [];
  List<String> _dayToDayPlans = [];
  String _selectedStudyPlan = "";
  String _selectedDayToDayPlan = "";
  List<TopicData> _topicData = [];
  int? _selectedTileIndex;

  @override
  void initState() {
    super.initState();
    _fetchStudyPlans();
  }

  void _fetchStudyPlans() async {
    DatabaseReference studyPlanRef =
        FirebaseDatabase.instance.ref("studyPlans");
    DataSnapshot snapshot = await studyPlanRef.get();

    if (snapshot.exists) {
      List plans = (snapshot.value as Map).keys.toList();
      setState(() {
        _studyPlans = plans.cast<String>();
      });
    }
  }

  void _fetchDayToDayPlans() async {
    if (_selectedStudyPlan.isEmpty) return;

    DatabaseReference dayToDayRef =
        FirebaseDatabase.instance.ref("daytoday/$_selectedStudyPlan");

    DataSnapshot snapshot = await dayToDayRef.get();
    if (!snapshot.exists) {
      setState(() {
        _dayToDayPlans = [];
      });
      return;
    }

    // Extract Day-to-Day Plans under the selected Study Plan
    Map<String, dynamic> data =
        Map<String, dynamic>.from(snapshot.value as Map);
    List<String> plans = data.keys.toList();

    setState(() {
      _dayToDayPlans = plans;
    });
  }

  void _fetchDayToDayTopics() async {
    if (_selectedStudyPlan.isEmpty || _selectedDayToDayPlan.isEmpty) return;

    DatabaseReference topicsRef = FirebaseDatabase.instance
        .ref("daytoday/$_selectedStudyPlan/$_selectedDayToDayPlan");

    DataSnapshot snapshot = await topicsRef.get();
    if (!snapshot.exists) {
      setState(() {
        _topicData = [];
      });
      return;
    }

    Map<String, dynamic> data =
        Map<String, dynamic>.from(snapshot.value as Map);
    List<TopicData> fetchedTopics = [];

    data.forEach((date, topicsMap) {
      DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(date);
      List<String> topics = List<String>.from((topicsMap as Map).keys);

      fetchedTopics.add(TopicData(
        date: parsedDate,
        topics: topics,
        isLocked: !_isAccessible(parsedDate),
      ));
    });

    setState(() {
      _topicData = fetchedTopics..sort((a, b) => a.date.compareTo(b.date));
    });
  }

  bool _isAccessible(DateTime date) {
    return date.isBefore(DateTime.now()) ||
        date.isAtSameMomentAs(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: PopupMenuButton<String>(
          icon: Icon(Icons.menu, color: Colors.white),
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
                  Icon(Icons.logout, color: darkPurple),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: const [
                  Icon(Icons.settings, color: darkPurple),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'storage',
              child: Row(
                children: const [
                  Icon(Icons.storage, color: darkPurple),
                  SizedBox(width: 8),
                  Text('Storage'),
                ],
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'STUDY COMPANION',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 22,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Gradient Background
          GradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildGlassmorphicButton(
                          title: 'CONTENT\nCREATION',
                          onTap: () {
                            log('Content Creation button pressed');
                            Navigator.of(context).pushNamed('input_screen');
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGlassmorphicButton(
                          title: 'DAY2DAY PLAN\nCREATION',
                          onTap: () {
                            log('Day2Day Plan Creation button pressed');
                            Navigator.of(context).pushNamed('daytoday_screen');
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Selectors and Topics
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Study Plan Selector with Glassmorphic Design
                          _buildGlassmorphicSelector(
                            child: _buildStudyPlanSelector(),
                          ),

                          // Day-to-Day Plan Selector
                          if (_dayToDayPlans.isNotEmpty)
                            _buildGlassmorphicSelector(
                              child: _buildDayToDayPlanSelector(),
                            ),

                          // Topics List with Enhanced Design
                          Expanded(
                            child: _buildEnhancedTopicsList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bottom Scrollable Area
                  _buildGlassmorphicScrollableArea(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Glassmorphic Button Design
  Widget _buildGlassmorphicButton(
      {required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  // Glassmorphic Selector Wrapper
  Widget _buildGlassmorphicSelector({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  // Enhanced Topics List
  Widget _buildEnhancedTopicsList() {
    return _selectedStudyPlan.isEmpty || _selectedDayToDayPlan.isEmpty
        ? Center(
            child: Text(
              "Select a Study Plan and Day-to-Day Plan",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          )
        : Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: _topicData.length,
              itemBuilder: (context, index) {
                final topic = _topicData[index];
                final isAccessible = _isAccessible(topic.date);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isAccessible
                        ? softPurple.withOpacity(0.5)
                        : Colors.grey.shade600.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAccessible
                          ? primaryPurple.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      DateFormat('MMM d').format(topic.date).toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isAccessible ? darkPurple : Colors.white70,
                      ),
                    ),
                    trailing: Icon(
                      isAccessible ? Icons.lock_open : Icons.lock,
                      color: isAccessible ? darkPurple : Colors.white70,
                    ),
                    onTap: isAccessible
                        ? () {
                            setState(() {
                              _selectedTileIndex =
                                  _selectedTileIndex == index ? null : index;
                            });
                          }
                        : null,
                  ),
                );
              },
            ),
          );
  }

  // Glassmorphic Scrollable Area
  Widget _buildGlassmorphicScrollableArea() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Daily Inspiration',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Your daily motivation and guidance will be displayed here. Stay focused, stay motivated!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    letterSpacing: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyPlanSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Expanded(
            child: Text(
              _selectedStudyPlan.isEmpty
                  ? "Select Study Plan"
                  : _selectedStudyPlan,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
              overflow: TextOverflow.ellipsis, // Prevent text overflow
            ),
          ),
          DropdownButton<String>(
            value: _selectedStudyPlan.isEmpty ? null : _selectedStudyPlan,
            dropdownColor: Colors.grey.shade700,
            underline: Container(),
            hint: const Text("Choose Plan",
                style: TextStyle(color: Colors.white)),
            style: const TextStyle(color: Colors.white),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedStudyPlan = newValue;
                  _selectedDayToDayPlan = "";
                  _fetchDayToDayPlans();
                });
              }
            },
            items: _studyPlans.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayToDayPlanSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _selectedDayToDayPlan.isEmpty
                  ? "Select Day-to-Day Plan"
                  : _selectedDayToDayPlan,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          DropdownButton<String>(
            value: _selectedDayToDayPlan.isEmpty ? null : _selectedDayToDayPlan,
            dropdownColor: Colors.grey.shade700,
            underline: Container(),
            hint: const Text("Choose Plan",
                style: TextStyle(color: Colors.black)),
            style: const TextStyle(color: Colors.black),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedDayToDayPlan = newValue;
                  _fetchDayToDayTopics();
                });
              }
            },
            items: _dayToDayPlans.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
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
