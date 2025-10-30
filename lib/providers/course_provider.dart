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

  // In course_provider.dart - update removeLinkFromCourse
void removeLinkFromCourse(String courseId, String linkId) {
  final course = getCourseById(courseId);
  if (course != null) {
    // Remove from course links
    final updatedLinks = course.links.where((link) => link.id != linkId).toList();
    
    // Remove from all info items that reference this link
    final updatedInfoItems = course.infoItems.map((infoItem) {
      final hasLink = infoItem.connectedLinks.any((link) => link.id == linkId);
      if (hasLink) {
        final updatedConnectedLinks = infoItem.connectedLinks.where((link) => link.id != linkId).toList();
        
        return InfoItem(
          id: infoItem.id,
          title: infoItem.title,
          description: infoItem.description,
          emoji: infoItem.emoji,
          createdAt: infoItem.createdAt,
          lastEdited: DateTime.now(),
          connectedLinks: updatedConnectedLinks,
          tags: infoItem.tags,
        );
      }
      return infoItem;
    }).toList();
    
    final updatedCourse = course.copyWith(
      links: updatedLinks,
      infoItems: updatedInfoItems,
      lastEdited: DateTime.now(),
    );
    updateCourse(courseId, updatedCourse);
  }
}

// In course_provider.dart - add this helper method
void _updateLinkEverywhere(String courseId, String linkId, String newTitle, String newUrl, bool isPassword) {
  final course = getCourseById(courseId);
  if (course == null) return;

  // Update in course links
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

  // Update in all info items that reference this link
  final updatedInfoItems = course.infoItems.map((infoItem) {
    final linkIndex = infoItem.connectedLinks.indexWhere((link) => link.id == linkId);
    if (linkIndex != -1) {
      final updatedConnectedLinks = List<Link>.from(infoItem.connectedLinks);
      updatedConnectedLinks[linkIndex] = Link(
        id: linkId,
        title: newTitle,
        url: newUrl,
        createdAt: infoItem.connectedLinks[linkIndex].createdAt,
        isPassword: isPassword,
      );
      
      return InfoItem(
        id: infoItem.id,
        title: infoItem.title,
        description: infoItem.description,
        emoji: infoItem.emoji,
        createdAt: infoItem.createdAt,
        lastEdited: DateTime.now(),
        connectedLinks: updatedConnectedLinks,
        tags: infoItem.tags,
      );
    }
    return infoItem;
  }).toList();

  final updatedCourse = course.copyWith(
    links: updatedLinks,
    infoItems: updatedInfoItems,
    lastEdited: DateTime.now(),
  );
  updateCourse(courseId, updatedCourse);
}

// Then update your existing method to use this helper:
void updateLinkInCourse(String courseId, String linkId, String newTitle, String newUrl, bool isPassword) {
  _updateLinkEverywhere(courseId, linkId, newTitle, newUrl, isPassword);
}

// In course_provider.dart - updated methods
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