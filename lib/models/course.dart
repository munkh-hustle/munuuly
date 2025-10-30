// course.dart
import 'link.dart';

class Course {
  String id;
  String name;
  String instructor;
  String roomLocation;
  String color;
  String? customIcon;
  DateTime createdAt;
  DateTime? lastEdited;
  DateTime? deadline;
  String? description;
  List<Link> links;
  List<InfoItem> infoItems; // New field for info items

  Course({
    required this.id,
    required this.name,
    required this.instructor,
    required this.roomLocation,
    required this.color,
    this.customIcon,
    required this.createdAt,
    this.lastEdited,
    this.deadline,
    this.description,
    List<Link>? links,
    List<InfoItem>? infoItems,
  })  : links = links ?? [],
        infoItems = infoItems ?? [];

  String get initials => name.isNotEmpty ? name[0].toUpperCase() : '';

  Course copyWith({
    String? id,
    String? name,
    String? instructor,
    String? roomLocation,
    String? color,
    String? customIcon,
    DateTime? createdAt,
    DateTime? lastEdited,
    DateTime? deadline,
    String? description,
    List<Link>? links,
    List<InfoItem>? infoItems,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      instructor: instructor ?? this.instructor,
      roomLocation: roomLocation ?? this.roomLocation,
      color: color ?? this.color,
      customIcon: customIcon ?? this.customIcon,
      createdAt: createdAt ?? this.createdAt,
      lastEdited: lastEdited ?? this.lastEdited,
      deadline: deadline ?? this.deadline,
      description: description ?? this.description,
      links: links ?? this.links,
      infoItems: infoItems ?? this.infoItems,
    );
  }
}

// In course.dart - updated InfoItem model
class InfoItem {
  String id;
  String title;
  String description;
  String emoji;
  DateTime createdAt;
  DateTime lastEdited;
  List<Link> connectedLinks; // Changed from single Link to List
  List<String> tags;

  InfoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.createdAt,
    required this.lastEdited,
    List<Link>? connectedLinks, // Updated parameter
    this.tags = const [],
  }) : connectedLinks = connectedLinks ?? [];
}