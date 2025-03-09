import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:developer';
import 'package:cccapp/service/auth/userid.dart';
import 'package:cccapp/service/pdf_viewer.dart';
import 'package:cccapp/widgets/bg.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cccapp/widgets/storage_dropdown.dart';
import 'package:cccapp/widgets/content_card.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({Key? key}) : super(key: key);
  static String routeName = "storage_screen";

  @override
  _StorageScreenState createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen>
    with SingleTickerProviderStateMixin {
  final String? userId = getUserId();
  final DatabaseReference ref = FirebaseDatabase.instance.refFromURL(
      "https://contextual-content-creation-default-rtdb.asia-southeast1.firebasedatabase.app/");

  String? selectedStudyPlan;
  String? selectedTopic;
  Map<String, dynamic> studyPlans = {};
  Map<String, dynamic> topics = {};
  bool isLoading = false;

  // For animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Define colors for consistent theming
  static const Color primaryPurple = Color(0xFF9C27B0);
  static const Color darkPurple = Color(0xFF6A1B9A);
  static const Color lightPurple = Color(0xFFCE93D8);

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    fetchStudyPlans();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void fetchStudyPlans() async {
    setState(() {
      isLoading = true;
    });

    DatabaseReference userRef = ref.child("users/${userId}/studyPlans");
    DatabaseEvent event = await userRef.once();

    if (event.snapshot.value != null) {
      setState(() {
        studyPlans = Map<String, dynamic>.from(event.snapshot.value as Map);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchTopics(String studyPlanId) async {
    setState(() {
      isLoading = true;
    });

    DatabaseReference planRef = ref.child("studyPlans/$studyPlanId");
    DatabaseEvent event = await planRef.once();

    if (event.snapshot.value != null) {
      setState(() {
        topics = Map<String, dynamic>.from(event.snapshot.value as Map);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchAndShowPDF(
      BuildContext context, String studyPlanId, String topic) async {
    try {
      setState(() {
        isLoading = true;
      });

      final DatabaseReference ref = FirebaseDatabase.instance.ref();
      DatabaseReference pdfRef =
          ref.child("studyPlans/$studyPlanId/$topic/pdfpages");

      DatabaseEvent event = await pdfRef.once();
      if (event.snapshot.value != null) {
        String pdfData = event.snapshot.value as String;

        if (pdfData.isNotEmpty) {
          // Remove surrounding quotes if present
          if (pdfData.startsWith('"') && pdfData.endsWith('"')) {
            pdfData = pdfData.substring(1, pdfData.length - 1);
          }

          // Remove any whitespace or unexpected newlines
          pdfData = pdfData.replaceAll(RegExp(r'\s+'), '');

          // Decode Base64 string into bytes
          Uint8List pdfBytes = base64Decode(pdfData);

          // Save PDF temporarily
          final tempDir = await getTemporaryDirectory();
          File pdfFile = File('${tempDir.path}/temp.pdf');
          await pdfFile.writeAsBytes(pdfBytes);

          setState(() {
            isLoading = false;
          });

          // Open PDF Viewer
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PDFViewerScreen(pdfPath: pdfFile.path, topicName: topic),
            ),
          );
        } else {
          setState(() {
            isLoading = false;
          });
          throw Exception("Invalid PDF format in database.");
        }
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception("No PDF found for this topic.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      log("Error fetching PDF: $e");

      // Show a more attractive error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 10),
                Text("PDF Not Available"),
              ],
            ),
            content: Text(
                "We couldn't retrieve the PDF for this topic. Please try again later."),
            actions: [
              TextButton(
                child: Text("OK", style: TextStyle(color: darkPurple)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
            backgroundColor: Colors.white.withOpacity(0.9),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'STUDY MATERIALS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 22,
          ),
        ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Motivational quote card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          darkPurple.withOpacity(0.7),
                          primaryPurple.withOpacity(0.5)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            color: Colors.amber[300], size: 32),
                        const SizedBox(height: 12),
                        const Text(
                          '"Study is the key that unlocks the door to opportunity."',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Study Plan Dropdown
                  StorageDropdown(
                    hint: "Select Study Plan",
                    value: selectedStudyPlan,
                    items: studyPlans.keys.toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedStudyPlan = newValue;
                        selectedTopic = null; // Reset topic selection
                        if (newValue != null) {
                          fetchTopics(newValue);
                        }
                      });
                    },
                    enabled: true,
                    darkPurple: darkPurple,
                  ),

                  // Topics Dropdown
                  StorageDropdown(
                    hint: "Select Topic",
                    value: selectedTopic,
                    items: topics.keys.toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTopic = newValue;
                      });
                    },
                    enabled: selectedStudyPlan != null,
                    darkPurple: darkPurple,
                  ),

                  // Loading indicator
                  if (isLoading)
                    Center(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        child: const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(lightPurple),
                        ),
                      ),
                    ),

                  // Display Content
                  if (selectedStudyPlan != null &&
                      selectedTopic != null &&
                      topics.containsKey(selectedTopic) &&
                      !isLoading)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Topic header with PDF button
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryPurple.withOpacity(0.6),
                                    darkPurple.withOpacity(0.8)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      selectedTopic!,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.picture_as_pdf,
                                        color: Colors.white),
                                    label: const Text("PDF"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[700],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                    ),
                                    onPressed: () {
                                      fetchAndShowPDF(context,
                                          selectedStudyPlan!, selectedTopic!);
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Summary card
                            ContentCard(
                              title: "Summary",
                              content: "${topics[selectedTopic]['summary']}",
                              icon: Icons.lightbulb_outline,
                              lightPurple: lightPurple,
                            ),

                            // Elaboration card
                            ContentCard(
                              title: "Elaboration",
                              content:
                                  "${topics[selectedTopic]['elaboration']}",
                              icon: Icons.auto_stories,
                              lightPurple: lightPurple,
                            ),

                            // Study tips card
                            ContentCard(
                              title: "Study Tips",
                              content:
                                  "Review the content above regularly. Try to explain the concepts in your own words. Connect this information with what you already know.",
                              icon: Icons.tips_and_updates,
                              lightPurple: lightPurple,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // When no content is selected yet
                  if ((selectedStudyPlan == null || selectedTopic == null) &&
                      !isLoading)
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.menu_book,
                                size: 60,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Select a Study Plan and Topic to begin",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
