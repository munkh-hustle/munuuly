// link_item.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/link.dart';
import 'package:flutter/services.dart'; // For Clipboard

class LinkItem extends StatelessWidget {
  final Link link;
  final VoidCallback onDelete;
  final Function(Link) onEdit;

  const LinkItem({
    super.key,
    required this.link,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          link.isPassword ? Icons.lock : Icons.link,
          color: link.isPassword ? Colors.orange : Colors.pink,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                link.title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            if (link.isPassword)
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () =>
                    _copyToClipboard(context, link.title, 'Username'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                link.isPassword ? '••••••••' : link.url,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
            if (link.isPassword)
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () =>
                    _copyToClipboard(context, link.url, 'Password'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit(link);
                break;
              case 'copy_title':
                _copyToClipboard(context, link.title, 'Username');
                break;
              case 'copy_url':
                _copyToClipboard(
                  context,
                  link.url,
                  link.isPassword ? 'Password' : 'URL',
                );
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'copy_title',
              child: Row(
                children: [
                  const Icon(Icons.copy, size: 20),
                  const SizedBox(width: 8),
                  Text(link.isPassword ? 'Copy Username' : 'Copy Title'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'copy_url',
              child: Row(
                children: [
                  const Icon(Icons.copy, size: 20),
                  const SizedBox(width: 8),
                  Text(link.isPassword ? 'Copy Password' : 'Copy URL'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          if (link.isPassword) {
            // For passwords, show a dialog with copy options
            _showPasswordDialog(context);
          } else {
            // For regular links, open in browser
            _launchURL(context, link.url);
          }
        },
      ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Password Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Username: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(child: Text(link.title)),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    _copyToClipboard(context, link.title, 'Username');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Password: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(child: Text(link.url)),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    _copyToClipboard(context, link.url, 'Password');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
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

  void _copyToClipboard(BuildContext context, String text, String type) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
