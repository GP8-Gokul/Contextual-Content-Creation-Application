import 'dart:developer';
import 'package:cccapp/widgets/bg.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class DaytoDayScreen extends StatefulWidget {
  static const routeName = 'daytoday_screen';
  @override
  _DaytoDayScreenState createState() => _DaytoDayScreenState();
}

class _DaytoDayScreenState extends State<DaytoDayScreen> {
  final DatabaseReference ref = FirebaseDatabase.instance.refFromURL(
      "https://contextual-content-creation-default-rtdb.asia-southeast1.firebasedatabase.app/");

  String? selectedPlanId;
  List<String> studyPlans = [];
  List<String> topics = [];
  DateTime? startDate;
  DateTime? endDate;

  static const Color darkPurple = Color(0xFF6A1B9A);

  @override
  void initState() {
    super.initState();
    fetchStudyPlans();
  }

  Future<void> fetchStudyPlans() async {
    DatabaseEvent event = await ref.child("studyPlans").once();
    Map? data = event.snapshot.value as Map?;
    if (data != null) {
      setState(() {
        studyPlans = data.keys.cast<String>().toList();
      });
    }
  }

  Future<void> fetchTopics(String planId) async {
    DatabaseEvent event = await ref.child("studyPlans/$planId/").once();
    Map? data = event.snapshot.value as Map?;
    if (data != null) {
      setState(() {
        topics = data.keys.cast<String>().toList();
      });
    }
  }

  void scheduleTopics() {
    log("🟢 scheduleTopics() called!");

    if (startDate == null ||
        endDate == null ||
        selectedPlanId == null ||
        topics.isEmpty) {
      log("⚠️ Missing required data! startDate: $startDate, endDate: $endDate, selectedPlanId: $selectedPlanId, topics: ${topics.length}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a study plan and dates.")),
      );
      return;
    }

    int totalDays = endDate!.difference(startDate!).inDays + 1;
    int totalTopics = topics.length;
    Map<String, Map<String, bool>> schedule = {};

    List<String> shuffledTopics = List.from(topics)..shuffle();
    int topicsPerDay = (totalTopics / totalDays).ceil();
    int topicIndex = 0;

    for (int i = 0; i < totalDays; i++) {
      DateTime currentDate = startDate!.add(Duration(days: i));
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
      schedule[formattedDate] = {};

      for (int j = 0; j < topicsPerDay && topicIndex < totalTopics; j++) {
        schedule[formattedDate]![shuffledTopics[topicIndex]] = true;
        topicIndex++;
      }
    }

    log("✅ schedule generated: $schedule");

    saveScheduleToDatabase(schedule);
  }

  Future<void> saveScheduleToDatabase(
      Map<String, Map<String, bool>> schedule) async {
    if (selectedPlanId == null) {
      log(" Error: selectedPlanId is null!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: No study plan selected!")),
      );
      return;
    }

    DatabaseReference planRef = ref.child("daytoday/$selectedPlanId");
    String? dayTodayId = planRef.push().key;

    if (dayTodayId == null) {
      log("Error: Failed to generate a unique dayTodayId!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Failed to generate study plan ID!")),
      );
      return;
    }

    try {
      log("🟢 Checking if 'daytoday/$selectedPlanId' exists...");
      DatabaseEvent event = await planRef.once();
      if (event.snapshot.value == null) {
        log("🔵 Creating 'daytoday/$selectedPlanId'...");
        await planRef.set({});
      }

      log("🟢 Saving schedule under ID: $dayTodayId");
      await planRef.child(dayTodayId).set(schedule);

      log("✅ Study plan successfully saved!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Study plan scheduled successfully!")),
      );
    } catch (error) {
      log("❌ Error saving schedule: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving schedule: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: darkPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context, 'main_screen');
          },
        ),
        title: const Text(
          'Study Plan Scheduler',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Stack(
        children: [
          GradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select a Study Plan",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      hint: Text("Choose a study plan"),
                      value: selectedPlanId,
                      items: studyPlans.map((plan) {
                        return DropdownMenuItem(
                          value: plan,
                          child: Text(plan),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPlanId = value;
                          topics.clear();
                        });
                        fetchTopics(value!);
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Select Date Range",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        DateTimeRange? picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            startDate = picked.start;
                            endDate = picked.end;
                          });
                        }
                      },
                      child: Text(startDate == null || endDate == null
                          ? "Pick Start & End Date"
                          : "${DateFormat('yyyy-MM-dd').format(startDate!)} → ${DateFormat('yyyy-MM-dd').format(endDate!)}"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: scheduleTopics,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          child: Text(
                            "Generate Study Plan",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
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
