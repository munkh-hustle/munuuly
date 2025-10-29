import 'package:flutter/material.dart';
import '../models/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: _getColorFromString(course.color),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // Emoji in the middle top
              Positioned(
                top: 36,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    course.customIcon ?? '📚',
                    style: const TextStyle(fontSize: 92),
                  ),
                ),
              ),
              // Course name at bottom left
              Positioned(
                bottom: 22,
                left: 12,
                right: 12,
                child: Text(
                  course.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorFromString(String colorString) {
    // Handle both named colors and Color objects
    if (colorString.startsWith('Color(0xff')) {
      // Extract hex value from Color object string
      final hexString = colorString.substring(10, colorString.length - 1);
      final colorValue = int.parse(hexString, radix: 16);
      return Color(colorValue);
    }
    
    // Handle named colors
    switch (colorString) {
      case 'pink': return Colors.pink;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'red': return Colors.red;
      case 'teal': return Colors.teal;
      case 'indigo': return Colors.indigo;
      default: 
        // Try to parse as hex if it's not a named color
        try {
          return Color(int.parse(colorString.replaceFirst('0x', ''), radix: 16));
        } catch (e) {
          return Colors.grey;
        }
    }
  }
}