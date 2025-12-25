
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
        ),
        home: const CourseListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
