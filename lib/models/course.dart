import 'link.dart'; // ADD THIS IMPORT

class Course {
  String id;
  String name;
  String instructor;
  String roomLocation;
  String color;
  String? customIcon;
  DateTime createdAt;
  List<Link> links;

  Course({
    required this.id,
    required this.name,
    required this.instructor,
    required this.roomLocation,
    required this.color,
    this.customIcon,
    required this.createdAt,
    List<Link>? links,
  }) : links = links ?? [];

  String get initials => name.isNotEmpty ? name[0].toUpperCase() : '';

  Course copyWith({
    String? id,
    String? name,
    String? instructor,
    String? roomLocation,
    String? color,
    String? customIcon,
    DateTime? createdAt,
    List<Link>? links,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      instructor: instructor ?? this.instructor,
      roomLocation: roomLocation ?? this.roomLocation,
      color: color ?? this.color,
      customIcon: customIcon ?? this.customIcon,
      createdAt: createdAt ?? this.createdAt,
      links: links ?? this.links,
    );
  }
}