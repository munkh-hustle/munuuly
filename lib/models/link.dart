// lib\models\link.dart
class Link {
  String id;
  String title;
  String url;
  DateTime createdAt;
  bool isPassword; 

  Link({
    required this.id,
    required this.title,
    required this.url,
    required this.createdAt,
    this.isPassword = false, 
  });
}
