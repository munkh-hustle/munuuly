// course_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course.dart';
import '../models/link.dart';

class CourseProvider with ChangeNotifier {
  final List<Course> _courses = [];
  String _sortBy = 'name';
  static const String _coursesKey = 'courses_data';
  static const String _sortByKey = 'sort_by';

  CourseProvider() {
    _loadData();
  }

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

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load sort preference
    _sortBy = prefs.getString(_sortByKey) ?? 'name';

    // Load courses data
    final coursesJson = prefs.getString(_coursesKey);
    if (coursesJson != null) {
      try {
        final List<dynamic> coursesList = json.decode(coursesJson);
        _courses.clear();
        _courses.addAll(
          coursesList.map((courseMap) => _courseFromMap(courseMap)),
        );
        notifyListeners();
      } catch (e) {
        print('Error loading courses: $e');
      }
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save sort preference
    await prefs.setString(_sortByKey, _sortBy);

    // Save courses data
    final coursesJson = json.encode(
      _courses.map((course) => _courseToMap(course)).toList(),
    );
    await prefs.setString(_coursesKey, coursesJson);
  }

  Map<String, dynamic> _courseToMap(Course course) {
    return {
      'id': course.id,
      'name': course.name,
      'instructor': course.instructor,
      'roomLocation': course.roomLocation,
      'color': course.color,
      'customIcon': course.customIcon,
      'createdAt': course.createdAt.toIso8601String(),
      'lastEdited': course.lastEdited?.toIso8601String(),
      'deadline': course.deadline?.toIso8601String(),
      'description': course.description,
      'links': course.links.map((link) => _linkToMap(link)).toList(),
      'infoItems': course.infoItems
          .map((infoItem) => _infoItemToMap(infoItem))
          .toList(),
      'photos':
          course.photos?.map((photo) => _photoToMap(photo)).toList() ?? [],
    };
  }

  Course _courseFromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      name: map['name'],
      instructor: map['instructor'],
      roomLocation: map['roomLocation'],
      color: map['color'],
      customIcon: map['customIcon'],
      createdAt: DateTime.parse(map['createdAt']),
      lastEdited: map['lastEdited'] != null
          ? DateTime.parse(map['lastEdited'])
          : null,
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'])
          : null,
      description: map['description'],
      links: List<Link>.from(
        map['links']?.map((linkMap) => _linkFromMap(linkMap)) ?? [],
      ),
      infoItems: List<InfoItem>.from(
        map['infoItems']?.map((infoMap) => _infoItemFromMap(infoMap)) ?? [],
      ),
      photos: List<Photo>.from(
        map['photos']?.map((photoMap) => _photoFromMap(photoMap)) ?? [],
      ),
    );
  }

  Map<String, dynamic> _linkToMap(Link link) {
    return {
      'id': link.id,
      'title': link.title,
      'url': link.url,
      'createdAt': link.createdAt.toIso8601String(),
      'isPassword': link.isPassword,
    };
  }

  Link _linkFromMap(Map<String, dynamic> map) {
    return Link(
      id: map['id'],
      title: map['title'],
      url: map['url'],
      createdAt: DateTime.parse(map['createdAt']),
      isPassword: map['isPassword'] ?? false,
    );
  }

  Map<String, dynamic> _infoItemToMap(InfoItem infoItem) {
    return {
      'id': infoItem.id,
      'title': infoItem.title,
      'description': infoItem.description,
      'emoji': infoItem.emoji,
      'createdAt': infoItem.createdAt.toIso8601String(),
      'lastEdited': infoItem.lastEdited.toIso8601String(),
      'connectedLinks': infoItem.connectedLinks
          .map((link) => _linkToMap(link))
          .toList(),
      'tags': infoItem.tags,
    };
  }

  InfoItem _infoItemFromMap(Map<String, dynamic> map) {
    return InfoItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      emoji: map['emoji'],
      createdAt: DateTime.parse(map['createdAt']),
      lastEdited: DateTime.parse(map['lastEdited']),
      connectedLinks: List<Link>.from(
        map['connectedLinks']?.map((linkMap) => _linkFromMap(linkMap)) ?? [],
      ),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Map<String, dynamic> _photoToMap(Photo photo) {
    return {
      'id': photo.id,
      'title': photo.title,
      'description': photo.description,
      'imagePath': photo.imagePath,
      'createdAt': photo.createdAt.toIso8601String(),
      'lastEdited': photo.lastEdited.toIso8601String(),
    };
  }

  Photo _photoFromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imagePath: map['imagePath'],
      createdAt: DateTime.parse(map['createdAt']),
      lastEdited: DateTime.parse(map['lastEdited']),
    );
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    _saveData();
    notifyListeners();
  }

  void addCourse(Course course) {
    _courses.add(course);
    _saveData();
    notifyListeners();
  }

  void updateCourse(String id, Course updatedCourse) {
    final index = _courses.indexWhere((course) => course.id == id);
    if (index != -1) {
      _courses[index] = updatedCourse;
      _saveData();
      notifyListeners();
    }
  }

  void deleteCourse(String id) {
    _courses.removeWhere((course) => course.id == id);
    _saveData();
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
      final updatedLinks = course.links
          .where((link) => link.id != linkId)
          .toList();
      final updatedInfoItems = course.infoItems.map((infoItem) {
        final hasLink = infoItem.connectedLinks.any(
          (link) => link.id == linkId,
        );
        if (hasLink) {
          final updatedConnectedLinks = infoItem.connectedLinks
              .where((link) => link.id != linkId)
              .toList();
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

  void updateLinkInCourse(
    String courseId,
    String linkId,
    String newTitle,
    String newUrl,
    bool isPassword,
  ) {
    _updateLinkEverywhere(courseId, linkId, newTitle, newUrl, isPassword);
  }

  void _updateLinkEverywhere(
    String courseId,
    String linkId,
    String newTitle,
    String newUrl,
    bool isPassword,
  ) {
    final course = getCourseById(courseId);
    if (course == null) return;

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

    final updatedInfoItems = course.infoItems.map((infoItem) {
      final linkIndex = infoItem.connectedLinks.indexWhere(
        (link) => link.id == linkId,
      );
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

  void updateInfoItemInCourse(
    String courseId,
    String infoItemId,
    InfoItem updatedInfoItem,
  ) {
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
      final updatedInfoItems = course.infoItems
          .where((item) => item.id != infoItemId)
          .toList();
      final updatedCourse = course.copyWith(
        infoItems: updatedInfoItems,
        lastEdited: DateTime.now(),
      );
      updateCourse(courseId, updatedCourse);
    }
  }

  // Photo methods
  void addPhotoToCourse(String courseId, Photo photo) {
    final course = getCourseById(courseId);
    if (course != null) {
      final updatedPhotos = [...course.photos ?? [], photo];
      final updatedCourse = course.copyWith(
        photos: updatedPhotos.cast<Photo>(), // Add .cast<Photo>() here
        lastEdited: DateTime.now(),
      );
      updateCourse(courseId, updatedCourse);
    }
  }

  void updatePhotoInCourse(
    String courseId,
    String photoId,
    Photo updatedPhoto,
  ) {
    final course = getCourseById(courseId);
    if (course != null) {
      final updatedPhotos =
          course.photos?.map((photo) {
            if (photo.id == photoId) {
              return updatedPhoto;
            }
            return photo;
          }).toList() ??
          [];

      // Cast the list to List<Photo> explicitly
      final updatedCourse = course.copyWith(
        photos: updatedPhotos.cast<Photo>(), // Add .cast<Photo>() here
        lastEdited: DateTime.now(),
      );
      updateCourse(courseId, updatedCourse);
    }
  }

  void removePhotoFromCourse(String courseId, String photoId) {
    final course = getCourseById(courseId);
    if (course != null) {
      final updatedPhotos =
          course.photos?.where((photo) => photo.id != photoId).toList() ?? [];
      final updatedCourse = course.copyWith(
        photos: updatedPhotos.cast<Photo>(), // Add .cast<Photo>() here
        lastEdited: DateTime.now(),
      );
      updateCourse(courseId, updatedCourse);
    }
  }
}
