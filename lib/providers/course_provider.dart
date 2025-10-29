import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../models/link.dart';

class CourseProvider with ChangeNotifier {
  final List<Course> _courses = [];

  List<Course> get courses => _courses;

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
}