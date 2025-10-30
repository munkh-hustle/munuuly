// Updated widgets/add_info_modal.dart
import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/link.dart';

class AddInfoModal extends StatefulWidget {
  final Function(String title, String description, String emoji, List<Link> connectedLinks, List<String> tags)? onInfoAdded;
  final Function(String title, String description, String emoji, List<Link> connectedLinks, List<String> tags)? onInfoUpdated;
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

// In add_info_modal.dart - replace the _showEmojiPicker method and related code

class _AddInfoModalState extends State<AddInfoModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _emojiController = TextEditingController(); // Add this controller
  String _selectedEmoji = '📝';
  List<Link> _selectedLinks = [];
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingInfoItem != null) {
      _titleController.text = widget.existingInfoItem!.title;
      _descriptionController.text = widget.existingInfoItem!.description;
      _selectedEmoji = widget.existingInfoItem!.emoji;
      _emojiController.text = widget.existingInfoItem!.emoji; // Initialize emoji controller
      _selectedLinks = List.from(widget.existingInfoItem!.connectedLinks);
      _tags = List.from(widget.existingInfoItem!.tags);
    } else {
      _emojiController.text = _selectedEmoji; // Initialize with default emoji
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
                // Emoji Selection - Updated to use TextField
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Emoji'),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _emojiController,
                      decoration: const InputDecoration(
                        hintText: 'Tap to enter emoji...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedEmoji = value.isNotEmpty ? value : '📝';
                        });
                      },
                      maxLength: 2, // Limit to 1-2 characters for emoji
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tip: Tap the field to open emoji keyboard',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Rest of your existing form fields remain the same...
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
                
                // Multiple Links Connection
                if (widget.availableLinks.isNotEmpty) ...[
                  const Text(
                    'Connect Links/Passwords:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.availableLinks.length,
                      itemBuilder: (context, index) {
                        final link = widget.availableLinks[index];
                        final isSelected = _selectedLinks.any((l) => l.id == link.id);
                        
                        return CheckboxListTile(
                          title: Text(
                            '${link.isPassword ? '🔐' : '🔗'} ${link.title}',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            link.isPassword ? '••••••••' : link.url,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: isSelected,
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedLinks.add(link);
                              } else {
                                _selectedLinks.removeWhere((l) => l.id == link.id);
                              }
                            });
                          },
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),
                  
                  // Selected links summary
                  if (_selectedLinks.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Selected: ${_selectedLinks.length} link${_selectedLinks.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
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

  // Remove the old _showEmojiPicker method and _commonEmojis list

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
          _selectedEmoji, // This will now use the emoji from the text field
          _selectedLinks,
          _tags,
        );
      } else if (widget.onInfoAdded != null) {
        widget.onInfoAdded!(
          _titleController.text,
          _descriptionController.text,
          _selectedEmoji, // This will now use the emoji from the text field
          _selectedLinks,
          _tags,
        );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _emojiController.dispose(); // Don't forget to dispose the controller
    super.dispose();
  }
}