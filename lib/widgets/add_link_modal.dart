// add_link_modal.dart
import 'package:flutter/material.dart';
import '../models/link.dart';

class AddLinkModal extends StatefulWidget {
  final Function(String title, String url) onLinkAdded;
  final Function(String title, String url)? onLinkUpdated;
  final Link? existingLink;

  const AddLinkModal({
    super.key,
    required this.onLinkAdded,
    this.onLinkUpdated,
    this.existingLink,
  });

  @override
  State<AddLinkModal> createState() => _AddLinkModalState();
}

class _AddLinkModalState extends State<AddLinkModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingLink != null) {
      _titleController.text = widget.existingLink!.title;
      _urlController.text = widget.existingLink!.url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingLink != null;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Edit Link' : 'Add New Link',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
                  onPressed: _saveLink,
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

  void _saveLink() {
    if (_formKey.currentState!.validate()) {
      if (widget.existingLink != null && widget.onLinkUpdated != null) {
        widget.onLinkUpdated!(_titleController.text, _urlController.text);
      } else {
        widget.onLinkAdded(_titleController.text, _urlController.text);
      }
      Navigator.of(context).pop();
    }
  }
}