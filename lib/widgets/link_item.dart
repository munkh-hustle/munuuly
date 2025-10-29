import 'package:flutter/material.dart';
import '../models/link.dart';

class LinkItem extends StatelessWidget {
  final Link link;
  final VoidCallback onDelete;

  const LinkItem({
    super.key,
    required this.link,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.link, color: Colors.pink),
        title: Text(
          link.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          link.url,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
        onTap: () {
          // TODO: Implement link opening functionality
        },
      ),
    );
  }
}