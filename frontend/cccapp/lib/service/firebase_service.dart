import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:cccapp/models/topic_data.dart';

class FirebaseService {
  // Fetch all study plans
  Future<List<String>> fetchStudyPlans() async {
    DatabaseReference studyPlanRef =
        FirebaseDatabase.instance.ref("studyPlans");
    DataSnapshot snapshot = await studyPlanRef.get();

    if (snapshot.exists) {
      List plans = (snapshot.value as Map).keys.toList();
      return plans.cast<String>();
    }
    return [];
  }

  // Fetch day-to-day plans for a specific study plan
  Future<List<String>> fetchDayToDayPlans(String studyPlan) async {
    if (studyPlan.isEmpty) return [];

    DatabaseReference dayToDayRef =
        FirebaseDatabase.instance.ref("daytoday/$studyPlan");

    DataSnapshot snapshot = await dayToDayRef.get();
    if (!snapshot.exists) {
      return [];
    }

    // Extract Day-to-Day Plans under the selected Study Plan
    Map<String, dynamic> data =
        Map<String, dynamic>.from(snapshot.value as Map);
    List<String> plans = data.keys.toList();

    return plans;
  }

  // Fetch topics for a specific day-to-day plan
  Future<List<TopicData>> fetchTopics(
      String studyPlan, String dayToDayPlan) async {
    if (studyPlan.isEmpty || dayToDayPlan.isEmpty) return [];

    DatabaseReference topicsRef =
        FirebaseDatabase.instance.ref("daytoday/$studyPlan/$dayToDayPlan");

    DataSnapshot snapshot = await topicsRef.get();
    if (!snapshot.exists) {
      return [];
    }

    Map<String, dynamic> data =
        Map<String, dynamic>.from(snapshot.value as Map);
    List<TopicData> fetchedTopics = [];

    data.forEach((date, topicsMap) {
      DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(date);
      Map<String, bool> topicsWithStatus = {};

      // Extract topics with their completion status
      (topicsMap as Map).forEach((topicKey, completionStatus) {
        // Handle the case where completion status is directly a boolean
        if (completionStatus is bool) {
          topicsWithStatus[topicKey] = completionStatus;
        } else {
          // Default to false if the format is unexpected
          topicsWithStatus[topicKey] = false;
        }
      });

      fetchedTopics.add(TopicData(
        date: parsedDate,
        topicsWithStatus: topicsWithStatus,
        isLocked: !TopicData.isAccessible(parsedDate),
      ));
    });

    // Sort topics by date
    fetchedTopics.sort((a, b) => a.date.compareTo(b.date));

    return fetchedTopics;
  }

  // Update topic completion status
  Future<void> updateTopicStatus(String studyPlan, String dayToDayPlan,
      String date, String topic, bool completed) async {
    DatabaseReference topicRef = FirebaseDatabase.instance
        .ref("daytoday/$studyPlan/$dayToDayPlan/$date/$topic");

    // Simply set the boolean value directly
    await topicRef.set(completed);
  }
}
