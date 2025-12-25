// lib/utils/import_export.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:munuuly/models/course.dart';
import 'package:munuuly/models/link.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/course_provider.dart';

class ImportExportService {
  static Future<void> exportAllData(CourseProvider courseProvider, BuildContext context) async {
    try {
      // Get all courses data
      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'courses': courseProvider.courses.map((course) {
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
            'links': course.links.map((link) {
              return {
                'id': link.id,
                'title': link.title,
                'url': link.url,
                'createdAt': link.createdAt.toIso8601String(),
                'isPassword': link.isPassword,
              };
            }).toList(),
            'infoItems': course.infoItems.map((infoItem) {
              return {
                'id': infoItem.id,
                'title': infoItem.title,
                'description': infoItem.description,
                'emoji': infoItem.emoji,
                'createdAt': infoItem.createdAt.toIso8601String(),
                'lastEdited': infoItem.lastEdited.toIso8601String(),
                'connectedLinks': infoItem.connectedLinks.map((link) {
                  return {
                    'id': link.id,
                    'title': link.title,
                    'url': link.url,
                    'createdAt': link.createdAt.toIso8601String(),
                    'isPassword': link.isPassword,
                  };
                }).toList(),
                'tags': infoItem.tags,
              };
            }).toList(),
            'photos': course.photos?.map((photo) {
              return {
                'id': photo.id,
                'title': photo.title,
                'description': photo.description,
                'imagePath': photo.imagePath,
                'createdAt': photo.createdAt.toIso8601String(),
                'lastEdited': photo.lastEdited.toIso8601String(),
              };
            }).toList() ?? [],
          };
        }).toList(),
      };

      // Convert to JSON
      final jsonString = JsonEncoder.withIndent('  ').convert(exportData);
      
      // Create file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/munuuly_export_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Munuuly Data Export',
        text: 'Here is your Munuuly data export from ${DateTime.now().toLocal()}',
      );
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported successfully (${courseProvider.courses.length} folders)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> importData(CourseProvider courseProvider, BuildContext context) async {
    try {
      // Pick JSON file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) return;
      
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final jsonData = json.decode(content);
      
      // Validate data structure
      if (jsonData['courses'] == null) {
        throw FormatException('Invalid export file format');
      }
      
      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Data'),
          content: Text(
            'This will import ${jsonData['courses'].length} folders and replace all current data. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Import', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      
      if (confirm != true) return;
      
      // Clear existing data first
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('courses_data');
      
      // Import new data
      final importedCourses = <Course>[];
      
      for (var courseData in jsonData['courses']) {
        try {
          final course = Course(
            id: courseData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            name: courseData['name'],
            instructor: courseData['instructor'],
            roomLocation: courseData['roomLocation'],
            color: courseData['color'],
            customIcon: courseData['customIcon'],
            createdAt: DateTime.parse(courseData['createdAt']),
            lastEdited: courseData['lastEdited'] != null 
                ? DateTime.parse(courseData['lastEdited'])
                : null,
            deadline: courseData['deadline'] != null
                ? DateTime.parse(courseData['deadline'])
                : null,
            description: courseData['description'],
            links: List<CourseLink>.from(
              (courseData['links'] as List).map((linkData) {
                return CourseLink(
                  id: linkData['id'],
                  title: linkData['title'],
                  url: linkData['url'],
                  createdAt: DateTime.parse(linkData['createdAt']),
                  isPassword: linkData['isPassword'] ?? false,
                );
              }),
            ),
            infoItems: List<InfoItem>.from(
              (courseData['infoItems'] as List).map((infoData) {
                return InfoItem(
                  id: infoData['id'],
                  title: infoData['title'],
                  description: infoData['description'],
                  emoji: infoData['emoji'],
                  createdAt: DateTime.parse(infoData['createdAt']),
                  lastEdited: DateTime.parse(infoData['lastEdited']),
                  connectedLinks: List<CourseLink>.from(
                    (infoData['connectedLinks'] as List).map((linkData) {
                      return CourseLink(
                        id: linkData['id'],
                        title: linkData['title'],
                        url: linkData['url'],
                        createdAt: DateTime.parse(linkData['createdAt']),
                        isPassword: linkData['isPassword'] ?? false,
                      );
                    }),
                  ),
                  tags: List<String>.from(infoData['tags'] ?? []),
                );
              }),
            ),
            photos: List<Photo>.from(
              (courseData['photos'] as List).map((photoData) {
                return Photo(
                  id: photoData['id'],
                  title: photoData['title'],
                  description: photoData['description'],
                  imagePath: photoData['imagePath'],
                  createdAt: DateTime.parse(photoData['createdAt']),
                  lastEdited: DateTime.parse(photoData['lastEdited']),
                );
              }),
            ),
          );
          importedCourses.add(course);
        } catch (e) {
          print('Error importing course ${courseData['name']}: $e');
        }
      }
      
      // Save imported courses to provider
      final coursesJson = json.encode(
        importedCourses.map((course) => _courseToMap(course)).toList(),
      );
      await prefs.setString('courses_data', coursesJson);
      
      // Notify provider to reload
      courseProvider.notifyListeners();
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully imported ${importedCourses.length} folders'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper method to convert course to map (similar to course_provider.dart)
  static Map<String, dynamic> _courseToMap(Course course) {
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
      'photos': course.photos?.map((photo) => _photoToMap(photo)).toList() ?? [],
    };
  }

  static Map<String, dynamic> _linkToMap(CourseLink link) {
    return {
      'id': link.id,
      'title': link.title,
      'url': link.url,
      'createdAt': link.createdAt.toIso8601String(),
      'isPassword': link.isPassword,
    };
  }

  static Map<String, dynamic> _infoItemToMap(InfoItem infoItem) {
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

  static Map<String, dynamic> _photoToMap(Photo photo) {
    return {
      'id': photo.id,
      'title': photo.title,
      'description': photo.description,
      'imagePath': photo.imagePath,
      'createdAt': photo.createdAt.toIso8601String(),
      'lastEdited': photo.lastEdited.toIso8601String(),
    };
  }
}