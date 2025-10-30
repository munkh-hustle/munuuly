import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';

class EditCourseScreen extends StatefulWidget {
  final Course? course;

  const EditCourseScreen({super.key, this.course});

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructorController = TextEditingController();
  final _roomController = TextEditingController();

  Color _selectedColor = Colors.pink;
  String _selectedEmoji = '📚'; // Default emoji
  final List<Color> _defaultColors = [
    Colors.pink,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _nameController.text = widget.course!.name;
      _instructorController.text = widget.course!.instructor;
      _roomController.text = widget.course!.roomLocation;
      _selectedColor = _getColorFromString(widget.course!.color);
      // Use customIcon field to store emoji, or default to book emoji
      _selectedEmoji = widget.course!.customIcon ?? '📚';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course == null ? 'New Folder' : 'Edit Folder'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Folder Icon with Emoji
              GestureDetector(
                onTap: _showEmojiPicker,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _selectedEmoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to change emoji',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              // Folder Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Folder',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter folder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _instructorController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Room Location Field
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Room Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Color Selection Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Color:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 12),

              // Color Picker - Horizontal Row
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Default Colors
                    ..._defaultColors.map(
                      (color) => _ColorCircle(
                        color: color,
                        isSelected: _selectedColor == color,
                        onTap: () => setState(() => _selectedColor = color),
                      ),
                    ),

                    // Custom Color Picker
                    _CustomColorPicker(
                      onColorPicked: (color) =>
                          setState(() => _selectedColor = color),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(widget.course == null ? 'Create' : 'Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmojiPicker() {
    // Show a dialog with a text field that will open the native emoji keyboard
    showDialog(
      context: context,
      builder: (context) => EmojiPickerDialog(
        currentEmoji: _selectedEmoji,
        onEmojiSelected: (emoji) {
          setState(() {
            _selectedEmoji = emoji;
          });
        },
      ),
    );
  }

  void _saveCourse() {
    if (_formKey.currentState!.validate()) {
      final courseProvider = Provider.of<CourseProvider>(
        context,
        listen: false,
      );
      final course = Course(
        id:
            widget.course?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        instructor: _instructorController.text,
        roomLocation: _roomController.text,
        color: _colorToString(_selectedColor),
        customIcon: _selectedEmoji, // Store the selected emoji
        createdAt: widget.course?.createdAt ?? DateTime.now(),
        links: widget.course?.links ?? [],
      );

      if (widget.course == null) {
        courseProvider.addCourse(course);
      } else {
        courseProvider.updateCourse(widget.course!.id, course);
      }

      Navigator.of(context).pop();
    }
  }

  Color _getColorFromString(String colorString) {
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
        // Try to parse as hex for custom colors
        try {
          return Color(int.parse(colorString, radix: 16));
        } catch (e) {
          return Colors.pink;
        }
    }
  }

  String _colorToString(Color color) {
    // For default colors, use names
    if (color == Colors.pink) return 'pink';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.green) return 'green';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.red) return 'red';
    if (color == Colors.teal) return 'teal';
    if (color == Colors.indigo) return 'indigo';

    // For custom colors, store the hex value
    return color.value.toRadixString(16);
  }
}

// Simple Emoji Picker Dialog that uses native keyboard
class EmojiPickerDialog extends StatefulWidget {
  final String currentEmoji;
  final Function(String) onEmojiSelected;

  const EmojiPickerDialog({
    super.key,
    required this.currentEmoji,
    required this.onEmojiSelected,
  });

  @override
  State<EmojiPickerDialog> createState() => _EmojiPickerDialogState();
}

class _EmojiPickerDialogState extends State<EmojiPickerDialog> {
  final TextEditingController _emojiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emojiController.text = widget.currentEmoji;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Emoji',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),

            // Current Selection Preview
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _emojiController.text.isEmpty ? '📚' : _emojiController.text,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Emoji Input Field
            TextField(
              controller: _emojiController,
              decoration: const InputDecoration(
                labelText: 'Enter emoji',
                border: OutlineInputBorder(),
                hintText: 'Tap to open emoji keyboard...',
              ),
              onChanged: (value) {
                widget.onEmojiSelected(value);
              },
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_emojiController.text.isNotEmpty) {
                        widget.onEmojiSelected(_emojiController.text);
                      }
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emojiController.dispose();
    super.dispose();
  }
}

// Color Circle Widget for individual color options
class _ColorCircle extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorCircle({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(color: Colors.white, width: 3)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Color Picker Widget
class _CustomColorPicker extends StatelessWidget {
  final Function(Color) onColorPicked;

  const _CustomColorPicker({required this.onColorPicked});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => _showColorPickerDialog(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: const Icon(Icons.add, color: Colors.grey),
        ),
      ),
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPickerGrid(
            onColorSelected: (color) {
              onColorPicked(color);
              Navigator.of(context).pop();
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// Color Picker Grid for Custom Colors
class ColorPickerGrid extends StatefulWidget {
  final Function(Color) onColorSelected;

  const ColorPickerGrid({super.key, required this.onColorSelected});

  @override
  State<ColorPickerGrid> createState() => _ColorPickerGridState();
}

class _ColorPickerGridState extends State<ColorPickerGrid> {
  final List<Color> _customColors = [
    Colors.red[100]!,
    Colors.red[300]!,
    Colors.red[500]!,
    Colors.red[700]!,
    Colors.red[900]!,
    Colors.pink[100]!,
    Colors.pink[300]!,
    Colors.pink[500]!,
    Colors.pink[700]!,
    Colors.pink[900]!,
    Colors.purple[100]!,
    Colors.purple[300]!,
    Colors.purple[500]!,
    Colors.purple[700]!,
    Colors.purple[900]!,
    Colors.deepPurple[100]!,
    Colors.deepPurple[300]!,
    Colors.deepPurple[500]!,
    Colors.deepPurple[700]!,
    Colors.deepPurple[900]!,
    Colors.indigo[100]!,
    Colors.indigo[300]!,
    Colors.indigo[500]!,
    Colors.indigo[700]!,
    Colors.indigo[900]!,
    Colors.blue[100]!,
    Colors.blue[300]!,
    Colors.blue[500]!,
    Colors.blue[700]!,
    Colors.blue[900]!,
    Colors.lightBlue[100]!,
    Colors.lightBlue[300]!,
    Colors.lightBlue[500]!,
    Colors.lightBlue[700]!,
    Colors.lightBlue[900]!,
    Colors.cyan[100]!,
    Colors.cyan[300]!,
    Colors.cyan[500]!,
    Colors.cyan[700]!,
    Colors.cyan[900]!,
    Colors.teal[100]!,
    Colors.teal[300]!,
    Colors.teal[500]!,
    Colors.teal[700]!,
    Colors.teal[900]!,
    Colors.green[100]!,
    Colors.green[300]!,
    Colors.green[500]!,
    Colors.green[700]!,
    Colors.green[900]!,
    Colors.lightGreen[100]!,
    Colors.lightGreen[300]!,
    Colors.lightGreen[500]!,
    Colors.lightGreen[700]!,
    Colors.lightGreen[900]!,
    Colors.lime[100]!,
    Colors.lime[300]!,
    Colors.lime[500]!,
    Colors.lime[700]!,
    Colors.lime[900]!,
    Colors.yellow[100]!,
    Colors.yellow[300]!,
    Colors.yellow[500]!,
    Colors.yellow[700]!,
    Colors.yellow[900]!,
    Colors.amber[100]!,
    Colors.amber[300]!,
    Colors.amber[500]!,
    Colors.amber[700]!,
    Colors.amber[900]!,
    Colors.orange[100]!,
    Colors.orange[300]!,
    Colors.orange[500]!,
    Colors.orange[700]!,
    Colors.orange[900]!,
    Colors.deepOrange[100]!,
    Colors.deepOrange[300]!,
    Colors.deepOrange[500]!,
    Colors.deepOrange[700]!,
    Colors.deepOrange[900]!,
    Colors.brown[100]!,
    Colors.brown[300]!,
    Colors.brown[500]!,
    Colors.brown[700]!,
    Colors.brown[900]!,
    Colors.grey[100]!,
    Colors.grey[300]!,
    Colors.grey[500]!,
    Colors.grey[700]!,
    Colors.grey[900]!,
    Colors.blueGrey[100]!,
    Colors.blueGrey[300]!,
    Colors.blueGrey[500]!,
    Colors.blueGrey[700]!,
    Colors.blueGrey[900]!,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _customColors.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => widget.onColorSelected(_customColors[index]),
            child: Container(
              decoration: BoxDecoration(
                color: _customColors[index],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
      ),
    );
  }
}
