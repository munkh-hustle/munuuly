// lib/models/link.dart
class CourseLink {
  String id;
  String title;
  String url;
  DateTime createdAt;
  bool isPassword; 

  CourseLink({
    required this.id,
    required this.title,
    required this.url,
    required this.createdAt,
    this.isPassword = false, 
  });
}