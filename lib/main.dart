// lib/
// ├── models/
// │   ├── course.dart
// │   └── link.dart
// ├── providers/
// │   └── course_provider.dart
// ├── screens/
// │   ├── course_list_screen.dart
// │   ├── edit_course_screen.dart
// │   └── course_detail_screen.dart
// ├── widgets/
// │   ├── course_card.dart
// │   ├── link_item.dart
// │   └── add_link_modal.dart
// └── main.dart
// lib\main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/course_provider.dart';
import 'screens/course_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CourseProvider(),
      child: MaterialApp(
        title: 'Course Manager',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          // Remove or comment out the custom font for now
          // fontFamily: 'YourCustomFont',
        ),
        home: const CourseListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}