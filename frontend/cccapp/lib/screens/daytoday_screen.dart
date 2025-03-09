import 'dart:developer';
import 'package:cccapp/widgets/bg.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cccapp/service/study_plan_service.dart';

class DaytoDayScreen extends StatefulWidget {
  static const routeName = 'daytoday_screen';
  @override
  _DaytoDayScreenState createState() => _DaytoDayScreenState();
}

class _DaytoDayScreenState extends State<DaytoDayScreen>
    with SingleTickerProviderStateMixin {
  final StudyPlanService _studyPlanService = StudyPlanService();

  String? selectedPlanId;
  String? existingDayToDayId;
  List<String> studyPlans = [];
  List<String> topics = [];
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = false;
  bool isCalendarVisible = false;
  bool hasExistingPlan = false;

  // Animation controller for calendar
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Colors
  static const Color darkPurple = Color(0xFF6A1B9A);
  static const Color primaryPurple = Color(0xFF6A1B9A);
  static const Color lightPurple = Color(0xFFBB86FC);
  static const Color accentColor = Color(0xFF03DAC5);
  static const Color warningColor = Color(0xFFF44336);

  @override
  void initState() {
    super.initState();
    _fetchStudyPlans();

    // Setup animation for calendar
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchStudyPlans() async {
    setState(() {
      isLoading = true;
    });

    try {
      final plans = await _studyPlanService.fetchStudyPlans();
      setState(() {
        studyPlans = plans;
      });
    } catch (e) {
      log("Error fetching study plans: $e");
      _showSnackBar("Failed to load study plans. Please try again.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchTopics(String planId) async {
    setState(() {
      isLoading = true;
      hasExistingPlan = false;
      existingDayToDayId = null;
    });

    try {
      // Check if a day-to-day plan already exists
      final existingId = await _studyPlanService.existingDayToDayPlanId(planId);

      final fetchedTopics = await _studyPlanService.fetchTopics(planId);

      setState(() {
        topics = fetchedTopics;
        if (existingId != null) {
          hasExistingPlan = true;
          existingDayToDayId = existingId;
        }
      });
    } catch (e) {
      log("Error fetching topics: $e");
      _showSnackBar("Failed to load topics. Please try again.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _toggleCalendar() {
    setState(() {
      isCalendarVisible = !isCalendarVisible;
    });

    if (isCalendarVisible) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (startDate == null || endDate != null) {
      // First selection or new selection after a complete range
      setState(() {
        startDate = selectedDay;
        endDate = null;
      });
    } else {
      // Second selection
      if (selectedDay.isBefore(startDate!)) {
        setState(() {
          endDate = startDate;
          startDate = selectedDay;
        });
      } else {
        setState(() {
          endDate = selectedDay;
        });
      }

      // Hide calendar after selection is complete
      if (endDate != null) {
        _toggleCalendar();
      }
    }
  }

  void _scheduleTopics() async {
    if (startDate == null ||
        endDate == null ||
        selectedPlanId == null ||
        topics.isEmpty) {
      _showSnackBar("Please select a study plan and date range first.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final success = await _studyPlanService.saveSchedule(
        selectedPlanId!,
        startDate!,
        endDate!,
        topics,
      );

      if (success) {
        _showSnackBar("Study plan scheduled successfully!");
        // Refresh to show the plan exists now
        _fetchTopics(selectedPlanId!);
      } else {
        if (hasExistingPlan) {
          _showSnackBar(
              "A plan already exists for this study plan. Please remove it first.");
          _showRemoveExistingPlanDialog();
        } else {
          _showSnackBar("Failed to schedule study plan. Please try again.");
        }
      }
    } catch (e) {
      log("Error scheduling topics: $e");
      _showSnackBar("An error occurred. Please try again.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showRemoveExistingPlanDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Existing Plan Found"),
          content: Text(
              "A day-to-day plan already exists for this study plan. Would you like to remove it and create a new one?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Remove & Create New"),
              onPressed: () {
                Navigator.of(context).pop();
                _removeExistingPlan();
              },
              style: TextButton.styleFrom(
                foregroundColor: warningColor,
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  Future<void> _removeExistingPlan() async {
    if (selectedPlanId == null || existingDayToDayId == null) {
      _showSnackBar("No existing plan to remove.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final success = await _studyPlanService.removeDayToDayPlan(
        selectedPlanId!,
        existingDayToDayId!,
      );

      if (success) {
        setState(() {
          hasExistingPlan = false;
          existingDayToDayId = null;
        });
        _showSnackBar(
            "Existing plan removed successfully. You can now create a new one.");
      } else {
        _showSnackBar("Failed to remove existing plan. Please try again.");
      }
    } catch (e) {
      log("Error removing existing plan: $e");
      _showSnackBar("An error occurred. Please try again.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: primaryPurple,
      ),
    );
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
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () {
            Navigator.pop(context, 'main_screen');
          },
        ),
        title: Text(
          'DAY TO DAY PLANNER',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
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
                    // Section 1: Study Plan Selection
                    _buildSectionTitle('Select a Study Plan', Icons.book),
                    SizedBox(height: 12),
                    _buildStudyPlanDropdown(),

                    // Show warning if plan exists
                    if (hasExistingPlan) _buildExistingPlanWarning(),

                    SizedBox(height: 24),

                    // Section 2: Date Range Selection
                    _buildSectionTitle(
                        'Select Date Range', Icons.calendar_today),
                    SizedBox(height: 12),
                    _buildDateRangeSelector(),
                    SizedBox(height: 16),

                    // Calendar (expandable)
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return SizeTransition(
                          sizeFactor: _animation,
                          child: child,
                        );
                      },
                      child: _buildCalendar(),
                    ),

                    SizedBox(height: 24),

                    // Section 3: Generate Button
                    _buildGenerateButton(),

                    SizedBox(height: 24),

                    // Topics Preview
                    if (topics.isNotEmpty) _buildTopicsPreview(),
                  ],
                ),
              ),
            ),
          ),

          // Loading Indicator
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExistingPlanWarning() {
    return Container(
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warningColor.withOpacity(0.1),
        border: Border.all(color: warningColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: warningColor),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "A day-to-day plan already exists for this study plan.",
              style: TextStyle(color: Colors.black87),
            ),
          ),
          TextButton(
            onPressed: () => _showRemoveExistingPlanDialog(),
            child: Text("REMOVE", style: TextStyle(color: warningColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStudyPlanDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          hintText: "Choose a study plan",
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
        icon: Icon(Icons.arrow_drop_down, color: primaryPurple),
        value: selectedPlanId,
        items: studyPlans.map((plan) {
          return DropdownMenuItem(
            value: plan,
            child: Text(
              plan,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedPlanId = value;
            topics.clear();
          });
          if (value != null) {
            _fetchTopics(value);
          }
        },
        isExpanded: true,
        dropdownColor: Colors.white,
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    String dateRangeText = "Select dates";

    if (startDate != null && endDate == null) {
      dateRangeText = "Start: ${DateFormat('MMM dd, yyyy').format(startDate!)}";
    } else if (startDate != null && endDate != null) {
      dateRangeText =
          "${DateFormat('MMM dd').format(startDate!)} - ${DateFormat('MMM dd, yyyy').format(endDate!)}";
    }

    return GestureDetector(
      onTap: _toggleCalendar,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.date_range, color: primaryPurple),
            SizedBox(width: 12),
            Text(
              dateRangeText,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Icon(
              isCalendarVisible
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(Duration(days: 365)),
        focusedDay: startDate ?? DateTime.now(),
        calendarFormat: CalendarFormat.month,
        selectedDayPredicate: (day) {
          return (startDate != null && isSameDay(day, startDate)) ||
              (endDate != null && isSameDay(day, endDate)) ||
              (startDate != null &&
                  endDate != null &&
                  day.isAfter(startDate!) &&
                  day.isBefore(endDate!));
        },
        rangeStartDay: startDate,
        rangeEndDay: endDate,
        onDaySelected: _onDaySelected,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          selectedDecoration: BoxDecoration(
            color: primaryPurple,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: lightPurple.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          rangeHighlightColor: lightPurple.withOpacity(0.2),
          withinRangeTextStyle: TextStyle(color: Colors.black87),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: primaryPurple,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: primaryPurple),
          rightChevronIcon: Icon(Icons.chevron_right, color: primaryPurple),
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    bool isEnabled = selectedPlanId != null &&
        startDate != null &&
        endDate != null &&
        topics.isNotEmpty &&
        !hasExistingPlan;

    String buttonText =
        hasExistingPlan ? "Remove Existing Plan First" : "Generate Study Plan";

    return Center(
      child: ElevatedButton(
        onPressed: isEnabled
            ? _scheduleTopics
            : (hasExistingPlan ? _showRemoveExistingPlanDialog : null),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(hasExistingPlan
                  ? Icons.warning_amber_rounded
                  : Icons.auto_awesome),
              SizedBox(width: 8),
              Text(
                buttonText,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: hasExistingPlan
              ? warningColor
              : (isEnabled ? accentColor : Colors.grey[400]),
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
      ),
    );
  }

  Widget _buildTopicsPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Selected Topics (${topics.length})', Icons.topic),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "These topics will be distributed across your selected date range:",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: topics.take(8).map((topic) {
                      return Chip(
                        label: Text(
                          topic,
                          style: TextStyle(fontSize: 12),
                        ),
                        backgroundColor: lightPurple.withOpacity(0.2),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      );
                    }).toList() +
                    (topics.length > 8
                        ? [
                            Chip(
                              label: Text(
                                "+${topics.length - 8} more",
                                style: TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.grey[300],
                            )
                          ]
                        : []),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
