class TopicData {
  final DateTime date;
  final Map<String, bool> topicsWithStatus;
  final bool isLocked;

  TopicData({
    required this.date,
    required this.topicsWithStatus,
    required this.isLocked,
  });

  // Helper method to check if a date is accessible (before or same as current date)
  static bool isAccessible(DateTime date) {
    return date.isBefore(DateTime.now()) ||
        date.isAtSameMomentAs(DateTime.now());
  }
}
