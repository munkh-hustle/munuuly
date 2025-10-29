// Updated info_item_card.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../models/course.dart';
import '../models/link.dart';

class InfoItemCard extends StatelessWidget {
  final InfoItem infoItem;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const InfoItemCard({
    super.key,
    required this.infoItem,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with emoji, title, and actions
              Row(
                children: [
                  // Emoji container
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        infoItem.emoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and metadata
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          infoItem.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        if (infoItem.tags.isNotEmpty)
                          Text(
                            infoItem.tags.take(2).join(', '),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  
                  // Quick actions
                  _buildQuickActions(context),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Description preview
              if (infoItem.description.isNotEmpty) ...[
                Text(
                  infoItem.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              // Metadata footer
              _buildMetadataFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Quick access to first link if available
      if (infoItem.connectedLinks.isNotEmpty)
        IconButton(
          icon: Icon(
            infoItem.connectedLinks.first.isPassword 
                ? Icons.lock_open 
                : Icons.open_in_new,
            size: 18,
            color: Colors.grey.shade600,
          ),
          onPressed: () => _handleQuickAccess(context, infoItem.connectedLinks.first),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      
      // More options
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, size: 18),
        onSelected: (value) => _handleMenuAction(context, value),
        itemBuilder: (BuildContext context) => [
          const PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
          if (infoItem.connectedLinks.isNotEmpty) ...[
            const PopupMenuItem<String>(
              value: 'show_links',
              child: Row(
                children: [
                  Icon(Icons.link, size: 18),
                  SizedBox(width: 8),
                  Text('Show All Links'),
                ],
              ),
            ),
          ],
          const PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red, size: 18),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

// Add method to show all links
void _handleMenuAction(BuildContext context, String value) {
  switch (value) {
    case 'edit':
      onEdit();
      break;
    case 'show_links':
      _showAllLinksDialog(context);
      break;
    case 'delete':
      onDelete();
      break;
  }
}

void _showAllLinksDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Connected Links'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: infoItem.connectedLinks.length,
          itemBuilder: (context, index) {
            final link = infoItem.connectedLinks[index];
            return ListTile(
              leading: Icon(link.isPassword ? Icons.lock : Icons.link),
              title: Text(link.title),
              subtitle: Text(link.isPassword ? '••••••••' : link.url),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    onPressed: () => _copyToClipboard(
                      context, 
                      link.isPassword ? link.url : link.title,
                      link.isPassword ? 'Password' : 'Title'
                    ),
                  ),
                  if (!link.isPassword)
                    IconButton(
                      icon: const Icon(Icons.open_in_new, size: 16),
                      onPressed: () => _launchURL(context, link.url),
                    ),
                ],
              ),
            );
          },
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

Widget _buildMetadataFooter() {
  return Wrap(
    spacing: 8,
    runSpacing: 4,
    children: [
      // Connected links indicators
      if (infoItem.connectedLinks.isNotEmpty)
        ...infoItem.connectedLinks.take(2).map((link) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  link.isPassword ? Icons.lock : Icons.link,
                  size: 10,
                  color: Colors.blue,
                ),
                const SizedBox(width: 2),
                Text(
                  link.title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      
      // Show "+X more" if there are more than 2 links
      if (infoItem.connectedLinks.length > 2)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '+${infoItem.connectedLinks.length - 2} more',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      
      // Last edited
      Text(
        'Edited ${_formatTimeAgo(infoItem.lastEdited)}',
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey.shade500,
        ),
      ),
    ],
  );
}
  void _handleQuickAccess(BuildContext context, Link link) {
    if (link.isPassword) {
      // Show password dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Password Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CopyableField(
                label: 'Username',
                value: link.title,
              ),
              const SizedBox(height: 12),
              _CopyableField(
                label: 'Password',
                value: link.url,
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
    } else {
      // Open URL
      _launchURL(context, link.url);
    }
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

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

// Helper widget for copyable fields
class _CopyableField extends StatelessWidget {
  final String label;
  final String value;

  const _CopyableField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontFamily: 'Monospace'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$label copied to clipboard'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}