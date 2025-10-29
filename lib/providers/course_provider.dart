// course_provider.dart
import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../models/link.dart';

class CourseProvider with ChangeNotifier {
  final List<Course> _courses = [];
  String _sortBy = 'name'; // Default sort by name

  List<Course> get courses {
    List<Course> sortedCourses = List.from(_courses);
    
    switch (_sortBy) {
      case 'emoji':
        sortedCourses.sort((a, b) {
          final emojiA = a.customIcon ?? '📚';
          final emojiB = b.customIcon ?? '📚';
          return emojiA.compareTo(emojiB);
        });
        break;
      case 'name':
      default:
        sortedCourses.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    
    return sortedCourses;
  }

  String get sortBy => _sortBy;

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  void addCourse(Course course) {
    _courses.add(course);
    notifyListeners();
  }

  void updateCourse(String id, Course updatedCourse) {
    final index = _courses.indexWhere((course) => course.id == id);
    if (index != -1) {
      _courses[index] = updatedCourse;
      notifyListeners();
    }
  }

  void deleteCourse(String id) {
    _courses.removeWhere((course) => course.id == id);
    notifyListeners();
  }

  Course? getCourseById(String id) {
    try {
      return _courses.firstWhere((course) => course.id == id);
    } catch (e) {
      return null;
    }
  }

  void addLinkToCourse(String courseId, Link link) {
    final course = getCourseById(courseId);
    if (course != null) {
      final updatedCourse = course.copyWith(links: [...course.links, link]);
      updateCourse(courseId, updatedCourse);
    }
  }

  void removeLinkFromCourse(String courseId, String linkId) {
    final course = getCourseById(courseId);
    if (course != null) {
      final updatedLinks = course.links.where((link) => link.id != linkId).toList();
      final updatedCourse = course.copyWith(links: updatedLinks);
      updateCourse(courseId, updatedCourse);
    }
  }

  // In the updateLinkInCourse method of course_provider.dart
void updateLinkInCourse(String courseId, String linkId, String newTitle, String newUrl, bool isPassword) {
  final course = getCourseById(courseId);
  if (course != null) {
    final updatedLinks = course.links.map((link) {
      if (link.id == linkId) {
        return Link(
          id: link.id,
          title: newTitle,
          url: newUrl,
          createdAt: link.createdAt,
          isPassword: isPassword,
        );
      }
      return link;
    }).toList();
    
    final updatedCourse = course.copyWith(links: updatedLinks);
    updateCourse(courseId, updatedCourse);
  }
}
// Add these methods to CourseProvider class in course_provider.dart

void addInfoItemToCourse(String courseId, InfoItem infoItem) {
  final course = getCourseById(courseId);
  if (course != null) {
    final updatedCourse = course.copyWith(
      infoItems: [...course.infoItems, infoItem],
      lastEdited: DateTime.now(),
    );
    updateCourse(courseId, updatedCourse);
  }
}

void updateInfoItemInCourse(String courseId, String infoItemId, InfoItem updatedInfoItem) {
  final course = getCourseById(courseId);
  if (course != null) {
    final updatedInfoItems = course.infoItems.map((item) {
      if (item.id == infoItemId) {
        return updatedInfoItem;
      }
      return item;
    }).toList();
    
    final updatedCourse = course.copyWith(
      infoItems: updatedInfoItems,
      lastEdited: DateTime.now(),
    );
    updateCourse(courseId, updatedCourse);
  }
}

void removeInfoItemFromCourse(String courseId, String infoItemId) {
  final course = getCourseById(courseId);
  if (course != null) {
    final updatedInfoItems = course.infoItems.where((item) => item.id != infoItemId).toList();
    final updatedCourse = course.copyWith(
      infoItems: updatedInfoItems,
      lastEdited: DateTime.now(),
    );
    updateCourse(courseId, updatedCourse);
  }
}
}