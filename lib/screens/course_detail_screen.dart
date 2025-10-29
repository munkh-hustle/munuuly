import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../widgets/add_link_modal.dart';
import '../widgets/link_item.dart'; // ADD THIS IMPORT
import '../models/course.dart'; // ADD THIS IMPORT
import '../models/link.dart'; // ADD THIS IMPORT
import 'edit_course_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> with SingleTickerProviderStateMixin {
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
    final course = Provider.of<CourseProvider>(context).getCourseById(widget.courseId);

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
            SliverToBoxAdapter(
              child: _buildCourseHeader(course),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'To-do'),
                    Tab(text: 'Files'),
                    Tab(text: 'Study Sets'),
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
            _buildTodoTab(),
            _buildFilesTab(),
            _buildStudySetsTab(),
            _buildLinksTab(course),
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
          // Course Icon/Image Upload
          GestureDetector(
            onTap: () {
              // TODO: Implement image upload
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getColorFromString(course.color),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: course.customIcon != null
                  ? Image.network(course.customIcon!)
                  : Icon(Icons.camera_alt, color: Colors.grey.shade400),
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
                    onLinkAdded: (title, url) {
                      final courseProvider = Provider.of<CourseProvider>(context, listen: false);
                      courseProvider.addLinkToCourse(
                        course.id,
                        Link(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: title,
                          url: url,
                          createdAt: DateTime.now(),
                        ),
                      );
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                          Provider.of<CourseProvider>(context, listen: false)
                              .removeLinkFromCourse(course.id, link.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoTab() => const Center(child: Text('To-do Content'));
  Widget _buildFilesTab() => const Center(child: Text('Files Content'));
  Widget _buildStudySetsTab() => const Center(child: Text('Study Sets Content'));

  Color _getColorFromString(String colorString) {
    switch (colorString) {
      case 'pink': return Colors.pink;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      default: return Colors.grey;
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}