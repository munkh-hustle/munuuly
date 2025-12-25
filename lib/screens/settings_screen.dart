// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../utils/import_export.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          // Data Management Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Data Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.download, color: Colors.blue),
            title: const Text('Export All Data'),
            subtitle: const Text('Create a backup of all folders and content'),
            onTap: () => ImportExportService.exportAllData(courseProvider, context),
          ),
          ListTile(
            leading: const Icon(Icons.upload, color: Colors.green),
            title: const Text('Import Data'),
            subtitle: const Text('Restore from a backup file'),
            onTap: () => ImportExportService.importData(courseProvider, context),
          ),
          const Divider(),
          
          // App Info Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'App Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.grey),
            title: const Text('App Version'),
            subtitle: const Text('1.0.3'),
          ),
          ListTile(
            leading: const Icon(Icons.folder, color: Colors.grey),
            title: const Text('Total Folders'),
            subtitle: Text('${courseProvider.courses.length} folders'),
          ),
          ListTile(
            leading: const Icon(Icons.link, color: Colors.grey),
            title: const Text('Total Links'),
            subtitle: Text('${courseProvider.courses.fold(0, (sum, course) => sum + course.links.length)} links'),
          ),
        ],
      ),
    );
  }
}