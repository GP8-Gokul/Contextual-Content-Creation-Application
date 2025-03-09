import 'package:flutter/material.dart';
import 'package:cccapp/widgets/bg.dart';
import 'package:cccapp/widgets/upload_section.dart';
import 'package:cccapp/widgets/keyword_input.dart';
import 'package:cccapp/widgets/error_message.dart';
import 'package:cccapp/widgets/keyword_section.dart';
import 'package:cccapp/widgets/submit_button.dart';
import 'package:cccapp/service/input_service.dart';
import 'package:cccapp/service/auth/userid.dart';
import 'dart:io';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});
  static String routeName = 'input_screen';

  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen>
    with SingleTickerProviderStateMixin {
  File? _selectedPDF;
  final List<String> _keywords = [];
  final TextEditingController _keywordController = TextEditingController();
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Enhanced custom colors
  static const Color primaryPurple = Color(0xFF9C27B0);
  static const Color darkPurple = Color(0xFF6A1B9A);
  static const Color lightPurple = Color(0xFFE1BEE7);
  static const Color backgroundStart = Color(0xFF1A1A1A);
  static const Color backgroundMid = Color(0xFF252525);
  static const Color accentColor = Color(0xFFAA00FF);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  void _addKeyword() {
    String keyword = _keywordController.text.trim();
    if (keyword.isEmpty) {
      setState(() {
        _errorMessage = 'Keyword cannot be empty';
      });
      return;
    }

    if (_keywords.contains(keyword)) {
      setState(() {
        _errorMessage = 'Keyword already exists';
      });
      return;
    }

    setState(() {
      _keywords.add(keyword);
      _keywordController.clear();
      _errorMessage = null;
    });
  }

  void _removeKeyword(String keyword) {
    setState(() {
      _keywords.remove(keyword);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context, 'main_screen');
          },
        ),
        title: const Text(
          'PDF Upload with Keywords',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              // Show info dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: backgroundMid,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text(
                    'How it works',
                    style: TextStyle(
                      color: lightPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text(
                    'Upload a PDF and add keywords to extract relevant information. The keywords will help identify important sections in your document.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Got it',
                        style: TextStyle(color: accentColor),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: backgroundStart,
      body: Stack(
        children: [
          const GradientBackground(),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // PDF Upload Section
                            UploadSection(
                              selectedPDF: _selectedPDF,
                              onPDFSelected: (file) {
                                setState(() {
                                  _selectedPDF = file;
                                });
                              },
                              onPDFRemoved: () {
                                setState(() {
                                  _selectedPDF = null;
                                });
                              },
                            ),

                            const SizedBox(height: 24),

                            // Keyword Input Section
                            KeywordInputSection(
                              controller: _keywordController,
                              onSubmit: _addKeyword,
                            ),

                            // Error Message section
                            if (_errorMessage != null)
                              ErrorMessage(message: _errorMessage!),

                            const SizedBox(height: 24),

                            // Keywords Display Section
                            if (_keywords.isNotEmpty)
                              KeywordsSection(
                                keywords: _keywords,
                                onRemove: _removeKeyword,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Fixed Submit Button at bottom
                  SubmitButton(
                    isEnabled: _selectedPDF != null && _keywords.isNotEmpty,
                    onPressed: () {
                      if (_selectedPDF != null && _keywords.isNotEmpty) {
                        // Call the PDFService to process the PDF and keywords
                        PDFService.uploadPDFWithKeywords(
                          pdf: _selectedPDF!,
                          keywords: _keywords,
                          userId:
                              getUserId()!, // You may need to get this from user context
                          onOutputReady: (output) {
                            // Handle the output
                          },
                          onError: (error) {
                            // Handle the error
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
