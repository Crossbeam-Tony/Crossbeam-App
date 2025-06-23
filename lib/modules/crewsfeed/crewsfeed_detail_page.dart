import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../services/data_service.dart';
import '../../shared/user_link.dart';
import '../../shared/avatar.dart';

class CrewsfeedDetailPage extends StatefulWidget {
  final Post post;
  const CrewsfeedDetailPage({super.key, required this.post});

  @override
  State<CrewsfeedDetailPage> createState() => _CrewsfeedDetailPageState();
}

class _CrewsfeedDetailPageState extends State<CrewsfeedDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final Map<String, bool> _likedComments = {};
  bool _isPostLiked = false;
  bool _isSubmitting = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    // Initialize liked state for comments
    for (final comment in widget.post.comments) {
      _likedComments[comment.id] = false;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _togglePostLike() {
    setState(() {
      _isPostLiked = !_isPostLiked;
    });
    HapticFeedback.lightImpact();
  }

  void _toggleCommentLike(String commentId) {
    setState(() {
      _likedComments[commentId] = !(_likedComments[commentId] ?? false);
    });
    HapticFeedback.lightImpact();
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    HapticFeedback.lightImpact();
  }

  void _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _commentController.clear();
      });
      _commentFocusNode.unfocus();

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment posted!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _addComment() {
    _submitComment();
  }

  void _showShareDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share Post',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),

            // Share options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.copy,
                  label: 'Copy Link',
                  onTap: () {
                    Navigator.pop(context);
                    _copyPostLink();
                  },
                ),
                _buildShareOption(
                  icon: Icons.share,
                  label: 'Share',
                  onTap: () {
                    Navigator.pop(context);
                    _sharePost();
                  },
                ),
                _buildShareOption(
                  icon: Icons.message,
                  label: 'Message',
                  onTap: () {
                    Navigator.pop(context);
                    _messagePost();
                  },
                ),
                _buildShareOption(
                  icon: Icons.email,
                  label: 'Email',
                  onTap: () {
                    Navigator.pop(context);
                    _emailPost();
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _copyPostLink() {
    // Simulate copying link
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _sharePost() {
    // Simulate sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing post...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _messagePost() {
    // Simulate messaging
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening message...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _emailPost() {
    // Simulate emailing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening email...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Why are you reporting this post?'),
            const SizedBox(height: 16),
            ...[
              'Spam',
              'Inappropriate content',
              'Harassment',
              'False information',
              'Other'
            ]
                .map((reason) => ListTile(
                      title: Text(reason),
                      onTap: () {
                        Navigator.pop(context);
                        _submitReport(reason);
                      },
                    ))
                .toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text(
            'Are you sure you want to block ${widget.post.author}? You won\'t see their posts anymore.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _blockUser();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _hidePost() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post hidden'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _submitReport(String reason) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report submitted: $reason'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _blockUser() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.post.author} has been blocked'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  String _getContentType() {
    switch (widget.post.type) {
      case PostType.event:
        return 'Event';
      case PostType.link:
        return 'Link';
      case PostType.photo:
        return 'Photo';
      case PostType.video:
        return 'Video';
      case PostType.text:
      default:
        return 'Post';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: false);
    final author = dataService.getUserByIdentifier(widget.post.authorId);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_getContentType()),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'share':
                  _showShareDialog();
                  break;
                case 'report':
                  _showReportDialog();
                  break;
                case 'block':
                  _showBlockDialog();
                  break;
                case 'hide':
                  _hidePost();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'hide',
                child: Row(
                  children: [
                    Icon(Icons.visibility_off),
                    SizedBox(width: 8),
                    Text('Hide post'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag),
                    SizedBox(width: 8),
                    Text('Report'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block),
                    SizedBox(width: 8),
                    Text('Block user'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Original post content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author info
                  if (author != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Avatar(
                            imageUrl: widget.post.authorAvatar ?? '',
                            size: 48,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  author.realname,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  '@${author.username} • ${_formatTimeAgo(widget.post.date)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),
                                ),
                                if (widget.post.crew.isNotEmpty)
                                  Text(
                                    'in ${widget.post.crew}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Post content
                  if (widget.post.title.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (widget.post.description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              widget.post.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),

                  // Post image
                  if (widget.post.imageUrl != null &&
                      widget.post.imageUrl!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(widget.post.imageUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Post actions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Like button
                        GestureDetector(
                          onTap: _togglePostLike,
                          child: Row(
                            children: [
                              Icon(
                                _isPostLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isPostLiked
                                    ? Colors.red
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.post.likes + (_isPostLiked ? 1 : 0)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Comment count
                        Row(
                          children: [
                            Icon(
                              Icons.comment,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.post.comments.length}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                        const Spacer(),

                        // Bookmark button
                        IconButton(
                          icon: Icon(
                            _isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: _isBookmarked
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                          ),
                          onPressed: _toggleBookmark,
                          tooltip:
                              _isBookmarked ? 'Remove bookmark' : 'Bookmark',
                        ),

                        // Share button
                        IconButton(
                          icon: Icon(
                            Icons.share,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                          onPressed: _showShareDialog,
                          tooltip: 'Share post',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Comments section header
                  Row(
                    children: [
                      Text(
                        'Comments',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${widget.post.comments.length})',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Comments list
                  if (widget.post.comments.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 48,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No comments yet',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Be the first to comment!',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.4),
                                ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...widget.post.comments
                        .map((comment) => _buildCommentItem(comment)),

                  const SizedBox(height: 100), // Space for input section
                ],
              ),
            ),
          ),

          // Comment input section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Avatar
                  const Avatar(
                    imageUrl: '', // Current user avatar
                    size: 32,
                  ),
                  const SizedBox(width: 12),

                  // Input field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.2),
                        ),
                      ),
                      child: TextField(
                        controller: _commentController,
                        focusNode: _commentFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          hintStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _submitComment(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Send button
                  GestureDetector(
                    onTap: _isSubmitting ? null : _submitComment,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isSubmitting
                            ? Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.1)
                            : Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.send,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 16,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with comment count
          Row(
            children: [
              Icon(
                Icons.comment_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Comments (${widget.post.comments.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  // TODO: Implement comment sorting
                },
                icon: const Icon(Icons.sort),
                tooltip: 'Sort comments',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Comment input section
          _buildCommentInput(),
          const SizedBox(height: 16),

          // Comments list
          if (widget.post.comments.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 8),
            ...widget.post.comments
                .map((comment) => _buildCommentItem(comment)),
          ] else ...[
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 48,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No comments yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Be the first to comment!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // User avatar
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Avatar(
              imageUrl:
                  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
              size: 32,
            ),
          ),
          const SizedBox(width: 12),

          // Comment input field
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),

          // Send button
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: _commentController.text.trim().isNotEmpty
                  ? _addComment
                  : null,
              icon: Icon(
                Icons.send,
                color: _commentController.text.trim().isNotEmpty
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              style: IconButton.styleFrom(
                backgroundColor: _commentController.text.trim().isNotEmpty
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                shape: const CircleBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Commenter avatar
          Avatar(
            imageUrl: comment.authorAvatar ??
                'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
            size: 36,
          ),
          const SizedBox(width: 12),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comment header
                Row(
                  children: [
                    Text(
                      comment.author,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeAgo(comment.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Comment text
                Text(
                  comment.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),

                // Comment actions
                Row(
                  children: [
                    // Reaction button
                    _buildReactionButton(comment),
                    const SizedBox(width: 16),

                    // Reply button
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement reply functionality
                      },
                      child: Text(
                        'Reply',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),

                    if (comment.replies.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          // TODO: Show replies
                        },
                        child: Text(
                          '${comment.replies.length} replies',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Show replies if any
                if (comment.replies.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.only(left: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: comment.replies
                          .take(2)
                          .map((reply) => _buildReplyItem(reply))
                          .toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyItem(Comment reply) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Avatar(
            imageUrl: reply.authorAvatar ??
                'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply.author,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeAgo(reply.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  reply.content,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton(Comment comment) {
    final reactions = ['👍', '❤️', '😂', '😮', '😢', '😠'];
    final reactionLabels = ['Like', 'Love', 'Laugh', 'Wow', 'Sad', 'Angry'];

    return PopupMenuButton<String>(
      offset: const Offset(0, -40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              comment.reaction ?? '👍',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_up,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => reactions.asMap().entries.map((entry) {
        final index = entry.key;
        final reaction = entry.value;
        return PopupMenuItem<String>(
          value: reaction,
          child: Row(
            children: [
              Text(reaction, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(reactionLabels[index]),
            ],
          ),
        );
      }).toList(),
      onSelected: (reaction) {
        // TODO: Update comment reaction
        setState(() {
          comment.reaction = reaction;
        });
      },
    );
  }
}
