import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class StudyPlanService {
  final DatabaseReference ref = FirebaseDatabase.instance.refFromURL(
      "https://contextual-content-creation-default-rtdb.asia-southeast1.firebasedatabase.app/");

  Future<List<String>> fetchStudyPlans() async {
    DatabaseEvent event = await ref.child("studyPlans").once();
    Map? data = event.snapshot.value as Map?;
    if (data != null) {
      return data.keys.cast<String>().toList();
    }
    return [];
  }

  Future<List<String>> fetchTopics(String planId) async {
    DatabaseEvent event = await ref.child("studyPlans/$planId/").once();
    Map? data = event.snapshot.value as Map?;
    if (data != null) {
      return data.keys.cast<String>().toList();
    }
    return [];
  }

  // Check if a day-to-day plan already exists for the study plan
  Future<String?> existingDayToDayPlanId(String studyPlanId) async {
    try {
      DatabaseEvent event = await ref.child("daytoday/$studyPlanId").once();
      Map? data = event.snapshot.value as Map?;

      if (data != null && data.isNotEmpty) {
        // Return the first key (dayTodayId) found
        return data.keys.cast<String>().first;
      }
      return null;
    } catch (error) {
      log("❌ Error checking existing plans: $error");
      return null;
    }
  }

  // Remove an existing day-to-day plan
  Future<bool> removeDayToDayPlan(String studyPlanId, String dayToDayId) async {
    try {
      await ref.child("daytoday/$studyPlanId/$dayToDayId").remove();
      log("✅ Removed day-to-day plan: $dayToDayId for study plan: $studyPlanId");
      return true;
    } catch (error) {
      log("❌ Error removing day-to-day plan: $error");
      return false;
    }
  }

  Future<bool> saveSchedule(String selectedPlanId, DateTime startDate,
      DateTime endDate, List<String> topics) async {
    if (startDate == null ||
        endDate == null ||
        selectedPlanId == null ||
        topics.isEmpty) {
      log("⚠️ Missing required data! startDate: $startDate, endDate: $endDate, selectedPlanId: $selectedPlanId, topics: ${topics.length}");
      return false;
    }

    try {
      // Check if a plan already exists for this study plan
      String? existingPlanId = await existingDayToDayPlanId(selectedPlanId);
      if (existingPlanId != null) {
        log("⚠️ A day-to-day plan already exists for this study plan: $existingPlanId");
        return false;
      }

      int totalDays = endDate.difference(startDate).inDays + 1;
      int totalTopics = topics.length;
      Map<String, Map<String, bool>> schedule = {};

      List<String> shuffledTopics = List.from(topics)..shuffle();
      int topicsPerDay = (totalTopics / totalDays).ceil();
      int topicIndex = 0;

      for (int i = 0; i < totalDays; i++) {
        DateTime currentDate = startDate.add(Duration(days: i));
        String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
        schedule[formattedDate] = {};

        for (int j = 0; j < topicsPerDay && topicIndex < totalTopics; j++) {
          schedule[formattedDate]![shuffledTopics[topicIndex]] = false;
          topicIndex++;
        }
      }

      log("✅ schedule generated: $schedule");

      DatabaseReference planRef = ref.child("daytoday/$selectedPlanId");
      String? dayTodayId = planRef.push().key;

      if (dayTodayId == null) {
        log("Error: Failed to generate a unique dayTodayId!");
        return false;
      }

      log("🟢 Checking if 'daytoday/$selectedPlanId' exists...");
      DatabaseEvent event = await planRef.once();
      if (event.snapshot.value == null) {
        log("🔵 Creating 'daytoday/$selectedPlanId'...");
        await planRef.set({});
      }

      log("🟢 Saving schedule under ID: $dayTodayId");
      await planRef.child(dayTodayId).set(schedule);

      log("✅ Study plan successfully saved!");
      return true;
    } catch (error) {
      log("❌ Error saving schedule: $error");
      return false;
    }
  }
}
