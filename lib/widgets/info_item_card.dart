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
  final VoidCallback? onToggleComplete;

  const InfoItemCard({
    super.key,
    required this.infoItem,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
    this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
  left: BorderSide(
    color: infoItem.priority.color,
    width: 4,
  ),
), 
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with emoji, title, and actions
                Row(
                  children: [
                    // Completion checkbox for tasks
                    if (infoItem.type == InfoType.task) ...[
                      IconButton(
                        icon: Icon(
                          infoItem.isCompleted 
                              ? Icons.check_circle 
                              : Icons.radio_button_unchecked,
                          color: infoItem.isCompleted ? Colors.green : Colors.grey,
                        ),
                        onPressed: onToggleComplete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                    ],
                    
                    // Emoji container
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getEmojiColor(infoItem.type),
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
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              decoration: infoItem.isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : TextDecoration.none,
                              color: infoItem.isCompleted 
                                  ? Colors.grey 
                                  : Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                infoItem.type.displayName,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (infoItem.tags.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '• ${infoItem.tags.take(2).join(', ')}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
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
                      decoration: infoItem.isCompleted 
                          ? TextDecoration.lineThrough 
                          : TextDecoration.none,
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
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick link access
        if (infoItem.connectedLink != null)
          IconButton(
            icon: Icon(
              infoItem.connectedLink!.isPassword 
                  ? Icons.lock_open 
                  : Icons.open_in_new,
              size: 18,
              color: Colors.grey.shade600,
            ),
            onPressed: () => _handleQuickAccess(context, infoItem.connectedLink!),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        
        // More options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 18),
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'edit',
              child: const Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            if (infoItem.connectedLink != null) ...[
              PopupMenuItem<String>(
                value: 'copy_link',
                child: Row(
                  children: [
                    const Icon(Icons.copy, size: 18),
                    const SizedBox(width: 8),
                    Text(infoItem.connectedLink!.isPassword 
                        ? 'Copy Password' 
                        : 'Copy URL'),
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

  Widget _buildMetadataFooter() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        // Deadline
        if (infoItem.deadline != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getDeadlineColor(infoItem.deadline!).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _getDeadlineColor(infoItem.deadline!).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 10,
                  color: _getDeadlineColor(infoItem.deadline!),
                ),
                const SizedBox(width: 2),
                Text(
                  _formatDeadline(infoItem.deadline!),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getDeadlineColor(infoItem.deadline!),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        
        // Priority
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: infoItem.priority.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: infoItem.priority.color.withOpacity(0.3)),
          ),
          child: Text(
            infoItem.priority.displayName,
            style: TextStyle(
              fontSize: 10,
              color: infoItem.priority.color,
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

  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        onEdit();
        break;
      case 'copy_link':
        if (infoItem.connectedLink != null) {
          _copyToClipboard(
            context, 
            infoItem.connectedLink!.url, 
            infoItem.connectedLink!.isPassword ? 'Password' : 'URL'
          );
        }
        break;
      case 'delete':
        onDelete();
        break;
    }
  }

  Color _getEmojiColor(InfoType type) {
    switch (type) {
      case InfoType.task: return Colors.blue.shade50;
      case InfoType.reminder: return Colors.orange.shade50;
      case InfoType.meeting: return Colors.purple.shade50;
      case InfoType.password: return Colors.red.shade50;
      case InfoType.link: return Colors.green.shade50;
      case InfoType.document: return Colors.blueGrey.shade50;
      case InfoType.idea: return Colors.yellow.shade50;
      default: return Colors.grey.shade100;
    }
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

  Color _getDeadlineColor(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    
    if (difference.inDays < 0) {
      return Colors.red; // Overdue
    } else if (difference.inDays <= 1) {
      return Colors.orange; // Due today or tomorrow
    } else if (difference.inDays <= 3) {
      return Colors.amber; // Due in 2-3 days
    } else {
      return Colors.green; // Due in more than 3 days
    }
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    
    if (difference.inDays < 0) {
      return 'Overdue by ${-difference.inDays} days';
    } else if (difference.inDays == 0) {
      return 'Due today';
    } else if (difference.inDays == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in ${difference.inDays} days';
    }
  }
}

// ADD THIS HELPER WIDGET OUTSIDE THE MAIN CLASS:

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