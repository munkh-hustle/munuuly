// lib\models\course.dart
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
  List<CourseLink> links;
  List<InfoItem> infoItems;
  List<Photo>? photos; 

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
    List<CourseLink>? links,
    List<InfoItem>? infoItems,
    List<Photo>? photos,
  }) : links = links ?? [],
       infoItems = infoItems ?? [],
       photos = photos ?? [];

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
    List<CourseLink>? links,
    List<InfoItem>? infoItems,
    List<Photo>? photos,
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
      photos: photos ?? this.photos,
    );
  }
}

class InfoItem {
  String id;
  String title;
  String description;
  String emoji;
  DateTime createdAt;
  DateTime lastEdited;
  List<CourseLink> connectedLinks;
  List<String> tags;

  InfoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.createdAt,
    required this.lastEdited,
    List<CourseLink>? connectedLinks,
    this.tags = const [],
  }) : connectedLinks = connectedLinks ?? [];
}

class Photo {
  String id;
  String title;
  String description;
  String imagePath; 
  DateTime createdAt;
  DateTime lastEdited;

  Photo({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.createdAt,
    required this.lastEdited,
  });
}