import 'package:flutter/material.dart';

class EnhancedDropdown extends StatelessWidget {
  final List<String> items;
  final String? selectedValue;
  final String hintText;
  final ValueChanged<String?> onChanged;

  const EnhancedDropdown({
    Key? key,
    required this.items,
    required this.selectedValue,
    required this.hintText,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color darkPurple = Color(0xFF6A1B9A);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 156, 13, 175).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: darkPurple.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: darkPurple,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                hintText,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            icon: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_drop_down_circle,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            isExpanded: true,
            dropdownColor: darkPurple.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            onChanged: onChanged,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
            selectedItemBuilder: (BuildContext context) {
              return items.map<Widget>((String value) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
