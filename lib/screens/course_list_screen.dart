// lib/screens/course_list_screen.dart
import 'package:flutter/material.dart';
import 'package:munuuly/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';
import 'edit_course_screen.dart';
import 'course_detail_screen.dart';
import '../utils/import_export.dart'; // Add this import

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Folders',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          // Export/Import Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) => _handleMenuAction(value, context),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Export All Data'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload, size: 20),
                    SizedBox(width: 8),
                    Text('Import Data'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'sort',
                child: Row(
                  children: [
                    Icon(Icons.sort, size: 20),
                    SizedBox(width: 8),
                    Text('Sort By'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: courseProvider.courses.length,
              itemBuilder: (context, index) {
                final course = courseProvider.courses[index];
                return CourseCard(
                  course: course,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CourseDetailScreen(courseId: course.id),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditCourseScreen()),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  void _handleMenuAction(String value, BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    switch (value) {
      case 'export':
        ImportExportService.exportAllData(courseProvider, context);
        break;
      case 'import':
        ImportExportService.importData(courseProvider, context);
        break;
      case 'sort':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sort Folders By'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: const Text('Name'),
                  trailing: courseProvider.sortBy == 'name'
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    courseProvider.setSortBy('name');
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.emoji_emotions),
                  title: const Text('Emoji'),
                  trailing: courseProvider.sortBy == 'emoji'
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    courseProvider.setSortBy('emoji');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
        break;
    }
  }
}
