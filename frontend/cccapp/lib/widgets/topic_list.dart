import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cccapp/models/topic_data.dart';

class TopicsList extends StatelessWidget {
  final String selectedStudyPlan;
  final String selectedDayToDayPlan;
  final List<TopicData> topicData;
  final int? selectedTileIndex;
  final Map<String, bool> topicCompletionStatus;
  final Function(int) onTileSelected;
  final Function(String, String, bool) onTopicStatusChanged;

  static const Color primaryPurple = Color(0xFF9C27B0);
  static const Color darkPurple = Color(0xFF6A1B9A);
  static const Color lightPurple = Color(0xFFCE93D8);

  const TopicsList({
    Key? key,
    required this.selectedStudyPlan,
    required this.selectedDayToDayPlan,
    required this.topicData,
    required this.selectedTileIndex,
    required this.topicCompletionStatus,
    required this.onTileSelected,
    required this.onTopicStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedStudyPlan.isEmpty || selectedDayToDayPlan.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            "Select a Study Plan and Day-to-Day Plan",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: topicData.length,
        itemBuilder: (context, index) {
          final topic = topicData[index];
          final isAccessible = TopicData.isAccessible(topic.date);
          final isSelected = index == selectedTileIndex;

          // Format date for display and for database reference
          final displayDate =
              DateFormat('MMM d').format(topic.date).toUpperCase();
          final dbDateFormat = DateFormat('yyyy-MM-dd').format(topic.date);

          return Column(
            children: [
              // Date Tile
              _buildDateTile(displayDate, isAccessible, isSelected,
                  () => isAccessible ? onTileSelected(index) : null),

              // Expanded topics with checkboxes
              if (isSelected && isAccessible)
                _buildExpandedTopicsList(topic.topicsWithStatus, dbDateFormat),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateTile(String displayDate, bool isAccessible, bool isSelected,
      VoidCallback? onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSelected && isAccessible
              ? [lightPurple.withOpacity(0.7), primaryPurple.withOpacity(0.4)]
              : isAccessible
                  ? [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1)
                    ]
                  : [
                      Colors.grey.shade600.withOpacity(0.3),
                      Colors.grey.shade800.withOpacity(0.3)
                    ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected && isAccessible
            ? [
                BoxShadow(
                  color: primaryPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          displayDate,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isAccessible ? Colors.white : Colors.white70,
          ),
        ),
        trailing: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isSelected && isAccessible
              ? Icon(
                  Icons.expand_less,
                  color: Colors.white,
                  key: ValueKey('expanded'),
                )
              : Icon(
                  isAccessible ? Icons.lock_open : Icons.lock,
                  color: isAccessible ? Colors.white : Colors.white70,
                  key: ValueKey('collapsed'),
                ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildExpandedTopicsList(
      Map<String, bool> topicsWithStatus, String dbDateFormat) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: topicsWithStatus.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "No topics for this day",
                style: TextStyle(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              children: topicsWithStatus.entries.map((entry) {
                final topicName = entry.key;
                final isCompleted =
                    topicCompletionStatus["$dbDateFormat-$topicName"] ??
                        entry.value;

                return _buildTopicItem(topicName, isCompleted, dbDateFormat);
              }).toList(),
            ),
    );
  }

  Widget _buildTopicItem(
      String topicName, bool isCompleted, String dbDateFormat) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted
            ? primaryPurple.withOpacity(0.3)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted
              ? lightPurple.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              topicName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isCompleted ? FontWeight.w400 : FontWeight.w500,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Theme(
            data: ThemeData(
              checkboxTheme: CheckboxThemeData(
                fillColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return primaryPurple;
                    }
                    return Colors.white;
                  },
                ),
                checkColor: MaterialStateProperty.all(Colors.white),
              ),
            ),
            child: Checkbox(
              value: isCompleted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (bool? value) {
                if (value != null) {
                  onTopicStatusChanged(dbDateFormat, topicName, value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
