import 'package:cccapp/service/auth/userid.dart';
import 'package:cccapp/widgets/bg.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class StudyPlanScreen extends StatefulWidget {
  const StudyPlanScreen({Key? key}) : super(key: key);
  static String routeName = "studyplan_screen";

  @override
  _StudyPlanScreenState createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends State<StudyPlanScreen> {
  final String? userId = getUserId();
  final DatabaseReference ref = FirebaseDatabase.instance.refFromURL(
      "https://contextual-content-creation-default-rtdb.asia-southeast1.firebasedatabase.app/");
  String? selectedStudyPlan;
  Map<String, dynamic> studyPlans = {};
  Map<String, dynamic> topics = {};

  @override
  void initState() {
    super.initState();
    fetchStudyPlans();
  }

  void fetchStudyPlans() async {
    DatabaseReference userRef = ref.child("users/${userId}/studyPlans");
    DatabaseEvent event = await userRef.once();
    if (event.snapshot.value != null) {
      setState(() {
        studyPlans = Map<String, dynamic>.from(event.snapshot.value as Map);
      });
    }
  }

  void fetchTopics(String studyPlanId) async {
    DatabaseReference planRef = ref.child("studyplan/$studyPlanId");
    DatabaseEvent event = await planRef.once();
    if (event.snapshot.value != null) {
      setState(() {
        topics = Map<String, dynamic>.from(event.snapshot.value as Map);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6A1B9A),
        centerTitle: true,
        title: const Text(
          'STUDYPLAN',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButton<String>(
                    value: selectedStudyPlan,
                    hint: const Text("Select Study Plan"),
                    isExpanded: true,
                    items: studyPlans.keys.map((String key) {
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Text("Study Plan: $key"),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedStudyPlan = newValue;
                        fetchTopics(newValue!);
                      });
                    },
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: topics.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6A1B9A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Summary: ${entry.value['summary']}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Elaboration: ${entry.value['elaboration']}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const Divider(height: 20, thickness: 1),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
