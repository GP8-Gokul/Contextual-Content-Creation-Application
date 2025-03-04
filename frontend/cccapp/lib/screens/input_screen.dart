import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cccapp/service/pdf_picker.dart';
import 'package:cccapp/widgets/bg.dart';
import 'dart:io';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});
  static String routeName = 'input_screen';

  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  File? _selectedPDF;
  final List<String> _keywords = [];
  final TextEditingController _keywordController = TextEditingController();
  String? _errorMessage;

  // Enhanced custom colors
  static const Color primaryPurple = Color(0xFF9C27B0);
  static const Color darkPurple = Color(0xFF6A1B9A);
  static const Color lightPurple = Color(0xFFE1BEE7);
  static const Color backgroundStart = Color(0xFF1A1A1A);
  static const Color backgroundMid = Color(0xFF252525);

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
        backgroundColor: darkPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context, 'main_screen');
          },
        ),
        title: const Text(
          'PDF Upload with Keywords',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      backgroundColor: backgroundStart,
      body: Stack(
        children: [
          // Fixed position gradient background
          const GradientBackground(),
          // Main content layout
          SafeArea(
            child: Column(
              children: [
                // Fixed content area
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PDF Upload Section
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [darkPurple, primaryPurple],
                            stops: const [0.3, 1.0],
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
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final file = await pickPDF();
                            if (file != null) {
                              setState(() {
                                _selectedPDF = file;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(
                            Icons.upload_file,
                            color: Colors.white,
                            size: 28,
                          ),
                          label: const Text(
                            'Select PDF File',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      if (_selectedPDF != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: darkPurple.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: lightPurple.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.description, color: lightPurple),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Selected: ${_selectedPDF!.path.split('/').last}',
                                  style: const TextStyle(
                                    color: lightPurple,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                color: Colors.redAccent,
                                onPressed: () {
                                  setState(() {
                                    _selectedPDF = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Keyword Input Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: backgroundMid.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: primaryPurple.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add Keywords',
                              style: TextStyle(
                                color: lightPurple,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _keywordController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'Type and press enter...',
                                      hintStyle: TextStyle(
                                        color: lightPurple.withOpacity(0.5),
                                      ),
                                      filled: true,
                                      fillColor:
                                          backgroundStart.withOpacity(0.5),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: primaryPurple.withOpacity(0.5),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: lightPurple,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onSubmitted: (_) => _addKeyword(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [darkPurple, primaryPurple],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryPurple.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.add_circle),
                                    onPressed: _addKeyword,
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Error Message section
                      if (_errorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.redAccent.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Keywords Header
                      if (_keywords.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.label, color: lightPurple),
                            const SizedBox(width: 8),
                            const Text(
                              'Your Keywords',
                              style: TextStyle(
                                color: lightPurple,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Scrollable Keywords Section
                if (_keywords.isNotEmpty)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: backgroundMid.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryPurple.withOpacity(0.2),
                            ),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _keywords.map((keyword) {
                              return Chip(
                                label: Text(
                                  keyword,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () => _removeKeyword(keyword),
                                backgroundColor: primaryPurple,
                                deleteIconColor: Colors.white,
                                elevation: 3,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Fixed Submit Button at bottom
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: (_selectedPDF != null && _keywords.isNotEmpty)
                            ? const [darkPurple, primaryPurple]
                            : [Colors.grey.shade800, Colors.grey.shade700],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryPurple.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: (_selectedPDF != null && _keywords.isNotEmpty)
                          ? () {
                              log('PDF: ${_selectedPDF!.path}');
                              log('Keywords: $_keywords');
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }
}
