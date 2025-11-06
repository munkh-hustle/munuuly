import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/course_provider.dart';
import '../widgets/add_link_modal.dart';
import '../widgets/add_photo_modal.dart';
import '../widgets/link_item.dart';
import '../models/course.dart';
import '../models/link.dart';
import '../widgets/photo_item.dart';
import 'edit_course_screen.dart';
import '../widgets/add_info_modal.dart';
import '../widgets/info_item_card.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final course = Provider.of<CourseProvider>(
      context,
    ).getCourseById(widget.courseId);

    if (course == null) {
      return const Scaffold(body: Center(child: Text('Course not found')));
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: _getColorFromString(course.color).withOpacity(0.3),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditCourseScreen(course: course),
                      ),
                    );
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(child: _buildCourseHeader(course)),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Info'),
                    Tab(text: 'Photos'),
                    Tab(text: 'Sets'),
                    Tab(text: 'Links'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTodoTab(course),
            _buildPhotosTab(course),
            _buildStudySetsTab(),
            _buildLinksTab(course),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosTab(Course course) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add Photo Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => AddPhotoModal(
                    onPhotoAdded: (title, description, imagePath) {
                      final courseProvider = Provider.of<CourseProvider>(
                        context,
                        listen: false,
                      );
                      courseProvider.addPhotoToCourse(
                        course.id,
                        Photo(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: title,
                          description: description,
                          imagePath: imagePath,
                          createdAt: DateTime.now(),
                          lastEdited: DateTime.now(),
                        ),
                      );
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text('+ Photo'),
            ),
          ),
          const SizedBox(height: 16),

          // Photos List
          Expanded(
            child: (course.photos?.isEmpty ?? true)
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No photos yet',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        Text(
                          'Add photos from your gallery',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: course.photos!.length,
                    itemBuilder: (context, index) {
                      final photo = course.photos![index];
                      return PhotoItem(
                        photo: photo,
                        onTap: () => _showPhotoDetail(context, photo),
                        onDelete: () {
                          Provider.of<CourseProvider>(
                            context,
                            listen: false,
                          ).removePhotoFromCourse(course.id, photo.id);
                        },
                        onEdit: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => AddPhotoModal(
                              existingPhoto: photo,
                              onPhotoUpdated: (title, description, imagePath) {
                                final courseProvider =
                                    Provider.of<CourseProvider>(
                                      context,
                                      listen: false,
                                    );
                                final updatedPhoto = Photo(
                                  id: photo.id,
                                  title: title,
                                  description: description,
                                  imagePath: imagePath,
                                  createdAt: photo.createdAt,
                                  lastEdited: DateTime.now(),
                                );
                                courseProvider.updatePhotoInCourse(
                                  course.id,
                                  photo.id,
                                  updatedPhoto,
                                );
                              },
                              onPhotoAdded:
                                  (
                                    title,
                                    description,
                                    imagePath,
                                  ) {}, // Not used in edit mode
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showPhotoDetail(BuildContext context, Photo photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      photo.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Image.file(
              File(photo.imagePath),
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            if (photo.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(photo.description),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseHeader(Course course) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Course Icon with Emoji
          GestureDetector(
            onTap: () {
              // TODO: Implement image upload or emoji change
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getColorFromString(course.color),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Text(
                  course.customIcon ?? '📚', // Use stored emoji or default
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            course.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${course.instructor} - ${course.roomLocation}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // In the _buildLinksTab method of course_detail_screen.dart
  Widget _buildLinksTab(Course course) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add Link Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => AddLinkModal(
                    onLinkAdded: (title, url, isPassword) {
                      final courseProvider = Provider.of<CourseProvider>(
                        context,
                        listen: false,
                      );
                      courseProvider.addLinkToCourse(
                        course.id,
                        Link(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: title,
                          url: url,
                          createdAt: DateTime.now(),
                          isPassword: isPassword,
                        ),
                      );
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text('+ Link'),
            ),
          ),
          const SizedBox(height: 16),
          // Links List
          Expanded(
            child: course.links.isEmpty
                ? const Center(
                    child: Text(
                      'No links added yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: course.links.length,
                    itemBuilder: (context, index) {
                      final link = course.links[index];
                      return LinkItem(
                        link: link,
                        onDelete: () {
                          Provider.of<CourseProvider>(
                            context,
                            listen: false,
                          ).removeLinkFromCourse(course.id, link.id);
                        },
                        onEdit: (linkToEdit) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => AddLinkModal(
                              existingLink: linkToEdit,
                              onLinkUpdated: (title, url, isPassword) {
                                final courseProvider =
                                    Provider.of<CourseProvider>(
                                      context,
                                      listen: false,
                                    );
                                courseProvider.updateLinkInCourse(
                                  course.id,
                                  linkToEdit.id,
                                  title,
                                  url,
                                  isPassword,
                                );
                              },
                              onLinkAdded:
                                  (
                                    title,
                                    url,
                                    isPassword,
                                  ) {}, // Not used in edit mode
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Replace the _buildTodoTab() method in course_detail_screen.dart
  // In course_detail_screen.dart - update the _buildTodoTab method
  // In course_detail_screen.dart - update the _buildTodoTab method
  Widget _buildTodoTab(Course course) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add Info Item Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => AddInfoModal(
                    onInfoAdded:
                        (title, description, emoji, connectedLinks, tags) {
                          // Updated parameter name
                          final courseProvider = Provider.of<CourseProvider>(
                            context,
                            listen: false,
                          );
                          final newInfoItem = InfoItem(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            title: title,
                            description: description,
                            emoji: emoji,
                            createdAt: DateTime.now(),
                            lastEdited: DateTime.now(),
                            connectedLinks:
                                connectedLinks, // Updated parameter name
                            tags: tags,
                          );
                          courseProvider.addInfoItemToCourse(
                            course.id,
                            newInfoItem,
                          );
                        },
                    availableLinks: course.links,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text('+ Info Item'),
            ),
          ),
          const SizedBox(height: 16),

          // Info Items List
          Expanded(
            child: course.infoItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note_add, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No information yet',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        Text(
                          'Add notes, tasks, reminders, or connect links',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: course.infoItems.length,
                    itemBuilder: (context, index) {
                      final infoItem = course.infoItems[index];
                      return InfoItemCard(
                        infoItem: infoItem,
                        onTap: () => _showInfoItemDetail(context, infoItem),
                        onDelete: () {
                          Provider.of<CourseProvider>(
                            context,
                            listen: false,
                          ).removeInfoItemFromCourse(course.id, infoItem.id);
                        },
                        onEdit: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => AddInfoModal(
                              existingInfoItem: infoItem,
                              onInfoUpdated:
                                  (
                                    title,
                                    description,
                                    emoji,
                                    connectedLinks,
                                    tags,
                                  ) {
                                    // Updated parameter name
                                    final courseProvider =
                                        Provider.of<CourseProvider>(
                                          context,
                                          listen: false,
                                        );
                                    final updatedInfoItem = InfoItem(
                                      id: infoItem.id,
                                      title: title,
                                      description: description,
                                      emoji: emoji,
                                      createdAt: infoItem.createdAt,
                                      lastEdited: DateTime.now(),
                                      connectedLinks:
                                          connectedLinks, // Updated parameter name
                                      tags: tags,
                                    );
                                    courseProvider.updateInfoItemInCourse(
                                      course.id,
                                      infoItem.id,
                                      updatedInfoItem,
                                    );
                                  },
                              availableLinks: course.links,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // In course_detail_screen.dart - update the _showInfoItemDetail method
  void _showInfoItemDetail(BuildContext context, InfoItem infoItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(infoItem.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(child: Text(infoItem.title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (infoItem.description.isNotEmpty) ...[
                Text(
                  infoItem.description,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
              ],

              // Connected links section
              if (infoItem.connectedLinks.isNotEmpty) ...[
                const Text(
                  'Connected Links:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...infoItem.connectedLinks.map((link) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          link.isPassword ? Icons.lock : Icons.link,
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                link.title,
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                link.isPassword ? '••••••••' : link.url,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          onPressed: () {
                            _copyToClipboard(
                              context,
                              link.isPassword ? link.url : link.title,
                              link.isPassword ? 'Password' : 'URL',
                            );
                          },
                        ),
                        if (!link.isPassword)
                          IconButton(
                            icon: const Icon(Icons.open_in_new, size: 16),
                            onPressed: () => _launchURL(context, link.url),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
              ],

              // Tags display
              if (infoItem.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  children: infoItem.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          backgroundColor: Colors.grey.shade100,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 8),
              Text(
                'Last edited: ${_formatDateTime(infoItem.lastEdited)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Add helper methods for clipboard and URL launching
  void _copyToClipboard(BuildContext context, String text, String type) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $url'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildStudySetsTab() =>
      const Center(child: Text('Study Sets Content'));

  Color _getColorFromString(String colorString) {
    // Handle both named colors and Color objects
    if (colorString.startsWith('Color(0xff')) {
      // Extract hex value from Color object string
      final hexString = colorString.substring(10, colorString.length - 1);
      final colorValue = int.parse(hexString, radix: 16);
      return Color(colorValue);
    }

    // Handle named colors
    switch (colorString) {
      case 'pink':
        return Colors.pink;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      case 'indigo':
        return Colors.indigo;
      default:
        // Try to parse as hex if it's not a named color
        try {
          return Color(
            int.parse(colorString.replaceFirst('0x', ''), radix: 16),
          );
        } catch (e) {
          return Colors.grey;
        }
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
