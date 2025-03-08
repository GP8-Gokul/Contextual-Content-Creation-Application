import 'dart:developer';
import 'package:cccapp/service/auth/logout.dart';
import 'package:cccapp/widgets/bg.dart';
import 'package:flutter/material.dart';
import 'package:cccapp/models/topic_data.dart';
import 'package:cccapp/widgets/glassmorphic_button.dart';
import 'package:cccapp/widgets/enhanced_dropdown.dart';
import 'package:cccapp/widgets/topic_list.dart';
import 'package:cccapp/widgets/glassmorphic_scrollable_area.dart';
import 'package:cccapp/service/firebase_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static String routeName = 'main_screen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const Color primaryPurple = Color(0xFF9C27B0);
  static const Color darkPurple = Color(0xFF6A1B9A);

  List<String> _studyPlans = [];
  List<String> _dayToDayPlans = [];
  String _selectedStudyPlan = "";
  String _selectedDayToDayPlan = "";
  List<TopicData> _topicData = [];
  int? _selectedTileIndex;
  Map<String, bool> _topicCompletionStatus = {};
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _fetchStudyPlans();
  }

  void _fetchStudyPlans() async {
    final plans = await _firebaseService.fetchStudyPlans();
    setState(() {
      _studyPlans = plans;
    });
  }

  void _fetchDayToDayPlans() async {
    if (_selectedStudyPlan.isEmpty) return;

    final plans = await _firebaseService.fetchDayToDayPlans(_selectedStudyPlan);
    setState(() {
      _dayToDayPlans = plans;
    });
  }

  void _fetchDayToDayTopics() async {
    if (_selectedStudyPlan.isEmpty || _selectedDayToDayPlan.isEmpty) return;

    final fetchedTopics = await _firebaseService.fetchTopics(
        _selectedStudyPlan, _selectedDayToDayPlan);

    setState(() {
      _topicData = fetchedTopics;
    });
  }

  void _updateTopicStatus(String date, String topic, bool completed) async {
    if (_selectedStudyPlan.isEmpty || _selectedDayToDayPlan.isEmpty) return;

    await _firebaseService.updateTopicStatus(
        _selectedStudyPlan, _selectedDayToDayPlan, date, topic, completed);

    // Update local state
    setState(() {
      String key = "$date-$topic";
      _topicCompletionStatus[key] = completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [darkPurple, primaryPurple.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
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
                        child: GlassmorphicButton(
                          title: 'CONTENT\nCREATION',
                          onTap: () {
                            log('Content Creation button pressed');
                            Navigator.of(context).pushNamed('input_screen');
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GlassmorphicButton(
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          // Enhanced Study Plan Selector
                          EnhancedDropdown(
                            items: _studyPlans,
                            selectedValue: _selectedStudyPlan.isEmpty
                                ? null
                                : _selectedStudyPlan,
                            hintText: "Select Study Plan",
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedStudyPlan = newValue;
                                  _selectedDayToDayPlan = "";
                                  _selectedTileIndex = null;
                                  _fetchDayToDayPlans();
                                });
                              }
                            },
                          ),

                          const SizedBox(height: 8),
                          // Enhanced Day-to-Day Plan Selector
                          if (_dayToDayPlans.isNotEmpty)
                            EnhancedDropdown(
                              items: _dayToDayPlans,
                              selectedValue: _selectedDayToDayPlan.isEmpty
                                  ? null
                                  : _selectedDayToDayPlan,
                              hintText: "Select Day-to-Day Plan",
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedDayToDayPlan = newValue;
                                    _selectedTileIndex = null;
                                    _fetchDayToDayTopics();
                                  });
                                }
                              },
                            ),

                          const SizedBox(height: 8),
                          // Topics List with Enhanced Design
                          Expanded(
                            child: TopicsList(
                              selectedStudyPlan: _selectedStudyPlan,
                              selectedDayToDayPlan: _selectedDayToDayPlan,
                              topicData: _topicData,
                              selectedTileIndex: _selectedTileIndex,
                              topicCompletionStatus: _topicCompletionStatus,
                              onTileSelected: (index) {
                                setState(() {
                                  _selectedTileIndex =
                                      _selectedTileIndex == index
                                          ? null
                                          : index;
                                });
                              },
                              onTopicStatusChanged: _updateTopicStatus,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bottom Scrollable Area
                  GlassmorphicScrollableArea(
                    title: 'Daily Inspiration',
                    content:
                        'Your daily motivation and guidance will be displayed here. Stay focused, stay motivated!',
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
