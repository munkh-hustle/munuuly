// widgets/add_info_modal.dart
import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/link.dart';

class AddInfoModal extends StatefulWidget {
  final Function(String title, String description, String emoji, Link? connectedLink, List<String> tags)? onInfoAdded;
  final Function(String title, String description, String emoji, Link? connectedLink, List<String> tags)? onInfoUpdated;
  final InfoItem? existingInfoItem;
  final List<Link> availableLinks;

  const AddInfoModal({
    super.key,
    this.onInfoAdded,
    this.onInfoUpdated,
    this.existingInfoItem,
    required this.availableLinks,
  });

  @override
  State<AddInfoModal> createState() => _AddInfoModalState();
}

class _AddInfoModalState extends State<AddInfoModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  String _selectedEmoji = '📝';
  Link? _selectedLink;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingInfoItem != null) {
      _titleController.text = widget.existingInfoItem!.title;
      _descriptionController.text = widget.existingInfoItem!.description;
      _selectedEmoji = widget.existingInfoItem!.emoji;
      _selectedLink = widget.existingInfoItem!.connectedLink;
      _tags = List.from(widget.existingInfoItem!.tags);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingInfoItem != null;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Edit Info Item' : 'Add New Info Item',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Emoji Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Emoji'),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _showEmojiPicker,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            _selectedEmoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                
                // Tags
                TextFormField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    labelText: 'Tags (comma separated)',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addTag,
                    ),
                  ),
                  onFieldSubmitted: (_) => _addTag(),
                ),
                const SizedBox(height: 8),
                
                // Display tags
                if (_tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    children: _tags.map((tag) => Chip(
                      label: Text(tag),
                      onDeleted: () => _removeTag(tag),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Link Connection
                if (widget.availableLinks.isNotEmpty) ...[
                  DropdownButtonFormField<Link?>(
                    value: _selectedLink,
                    decoration: const InputDecoration(
                      labelText: 'Connect to Link/Password (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('No connection'),
                      ),
                      ...widget.availableLinks.map((link) {
                        return DropdownMenuItem(
                          value: link,
                          child: Text(
                            '${link.isPassword ? '🔐' : '🔗'} ${link.title}',
                          ),
                        );
                      }).toList(),
                    ],
                    onChanged: (Link? link) {
                      setState(() {
                        _selectedLink = link;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: _saveInfoItem,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.pink),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    isEditing ? 'Update' : 'Create',
                    style: const TextStyle(color: Colors.pink),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _addTag() {
    final tag = _tagsController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _saveInfoItem() {
    if (_formKey.currentState!.validate()) {
      if (widget.existingInfoItem != null && widget.onInfoUpdated != null) {
        widget.onInfoUpdated!(
          _titleController.text,
          _descriptionController.text,
          _selectedEmoji,
          _selectedLink,
          _tags,
        );
      } else if (widget.onInfoAdded != null) {
        widget.onInfoAdded!(
          _titleController.text,
          _descriptionController.text,
          _selectedEmoji,
          _selectedLink,
          _tags,
        );
      }
      Navigator.of(context).pop();
    }
  }

  void _showEmojiPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Emoji'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _commonEmojis.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedEmoji = _commonEmojis[index];
                  });
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade100,
                  ),
                  child: Center(
                    child: Text(
                      _commonEmojis[index],
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  final List<String> _commonEmojis = [
    '📝', '📚', '📖', '🎯', '⏰', '📅',
    '🔗', '🔐', '📎', '📋', '📁', '📂',
    '💡', '⭐', '🎓', '📊', '📈', '📉',
    '🔄', '✅', '❌', '⚠️', '🔔', '🎉',
  ];
}