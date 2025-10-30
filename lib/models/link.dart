// link.dart
class Link {
  String id;
  String title;
  String url;
  DateTime createdAt;
  bool isPassword; // New field to distinguish between link and password

  Link({
    required this.id,
    required this.title,
    required this.url,
    required this.createdAt,
    this.isPassword = false, // Default to false (regular link)
  });
}
