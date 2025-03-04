import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:developer';
import 'package:cccapp/service/auth/userid.dart';
import 'package:cccapp/widgets/bg.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({Key? key}) : super(key: key);
  static String routeName = "storage_screen";

  @override
  _StorageScreenState createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final String? userId = getUserId();
  final DatabaseReference ref = FirebaseDatabase.instance.refFromURL(
      "https://contextual-content-creation-default-rtdb.asia-southeast1.firebasedatabase.app/");

  String? selectedStudyPlan;
  String? selectedTopic;
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
    DatabaseReference planRef = ref.child("studyPlans/$studyPlanId");
    DatabaseEvent event = await planRef.once();
    if (event.snapshot.value != null) {
      setState(() {
        topics = Map<String, dynamic>.from(event.snapshot.value as Map);
      });
    }
  }

  void fetchAndShowPDF(
      BuildContext context, String studyPlanId, String topic) async {
    try {
      final DatabaseReference ref = FirebaseDatabase.instance.ref();
      DatabaseReference pdfRef =
          ref.child("studyPlans/$studyPlanId/$topic/pdfpages");

      DatabaseEvent event = await pdfRef.once();
      if (event.snapshot.value != null) {
        String pdfData = event.snapshot.value as String;

        if (pdfData.isNotEmpty) {
          // 🔹 Remove surrounding quotes if present
          if (pdfData.startsWith('"') && pdfData.endsWith('"')) {
            pdfData = pdfData.substring(1, pdfData.length - 1);
          }

          // 🔹 Remove any whitespace or unexpected newlines
          pdfData = pdfData.replaceAll(RegExp(r'\s+'), '');

          // ✅ Decode Base64 string into bytes
          Uint8List pdfBytes = base64Decode(pdfData);

          // 📝 Save PDF temporarily
          final tempDir = await getTemporaryDirectory();
          File pdfFile = File('${tempDir.path}/temp.pdf');
          await pdfFile.writeAsBytes(pdfBytes);

          // 📜 Open PDF Viewer
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFViewerScreen(pdfPath: pdfFile.path),
            ),
          );
        } else {
          throw Exception("Invalid PDF format in database.");
        }
      } else {
        throw Exception("No PDF found for this topic.");
      }
    } catch (e) {
      log("Error fetching PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to retrieve PDF: $e")),
      );
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
                // Study Plan Dropdown
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButton<String>(
                    value: selectedStudyPlan,
                    hint: const Text(
                      "Select Study Plan",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    isExpanded: true,
                    items: studyPlans.keys.map((String key) {
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Text(
                          key,
                          style: TextStyle(
                            color: const Color.fromARGB(255, 206, 19, 206),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedStudyPlan = newValue;
                        selectedTopic = null; // Reset topic selection
                        if (newValue != null) {
                          fetchTopics(newValue);
                        }
                      });
                    },
                  ),
                ),

                // Topics Dropdown
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButton<String>(
                    value: selectedTopic,
                    hint: const Text(
                      "Select Topic",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    isExpanded: true,
                    items: selectedStudyPlan == null
                        ? []
                        : topics.keys.map((String key) {
                            return DropdownMenuItem<String>(
                              value: key,
                              child: Text(
                                key,
                                style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 206, 19, 206),
                                ),
                              ),
                            );
                          }).toList(),
                    onChanged: selectedStudyPlan == null
                        ? null
                        : (String? newValue) {
                            setState(() {
                              selectedTopic = newValue;
                            });
                          },
                  ),
                ),

                // Display Content
                if (selectedStudyPlan != null &&
                    selectedTopic != null &&
                    topics.containsKey(selectedTopic))
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedTopic!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6A1B9A),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf,
                                    color: Colors.red),
                                onPressed: () {
                                  fetchAndShowPDF(context, selectedStudyPlan!,
                                      selectedTopic!);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Summary:",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${topics[selectedTopic]['summary']}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Elaboration:",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${topics[selectedTopic]['elaboration']}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
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

class PDFViewerScreen extends StatelessWidget {
  final String pdfPath;

  const PDFViewerScreen({Key? key, required this.pdfPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Viewer")),
      body: PDFView(
        filePath: pdfPath,
      ),
    );
  }
}
