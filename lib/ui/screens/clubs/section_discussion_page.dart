import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/club_dao.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/clubs_provider.dart';

class SectionDiscussionPage extends ConsumerStatefulWidget {
  const SectionDiscussionPage({
    super.key,
    required this.clubUuid,
    this.bookUuid,
    required this.sectionNumber,
    required this.totalChapters,
  });

  final String clubUuid;
  final String? bookUuid;
  final int sectionNumber;
  final int totalChapters;

  @override
  ConsumerState<SectionDiscussionPage> createState() =>
      _SectionDiscussionPageState();
}

class _SectionDiscussionPageState extends ConsumerState<SectionDiscussionPage> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  bool _isSending = false;
  bool _isSpoiler = false;
  CommentWithUser? _replyTo;

  @override
  void dispose() {
    _focusNode.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final user = ref.read(activeUserProvider).value;
    if (user == null || user.remoteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para comentar')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

        try {
      await ref.read(sectionCommentServiceProvider).postComment(
            clubUuid: widget.clubUuid,
            bookUuid: widget.bookUuid,
            sectionNumber: widget.sectionNumber,
            userUuid: user.remoteId!,
            content: content,
            parentId: _replyTo?.comment.uuid,
            isSpoiler: _isSpoiler,
          );
      _commentController.clear();
      setState(() {
        _replyTo = null;
        _isSpoiler = false;
      });
      // Scroll to bottom after sending
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, // Reverse list, 0 is bottom
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar comentario: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(sectionCommentsProvider(
        (clubUuid: widget.clubUuid, bookUuid: widget.bookUuid, sectionNumber: widget.sectionNumber)));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookUuid == null ? 'Chat General' : 'Discusión Sección ${widget.sectionNumber}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: commentsAsync.when(
              data: (comments) {
                if (comments.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Sé el primero en comentar',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse:
                      true, // Newest at bottom visually if we reverse list?
                  // Usually chat is reverse: true, index 0 is bottom (newest).
                  // But our DAO orders by createdAt ASC (oldest first).
                  // So index 0 is oldest.
                  // If we use reverse: true, index 0 (oldest) will be at bottom. That's wrong.
                  // We want newest at bottom.
                  // If DAO returns Oldest -> Newest.
                  // List: [Old, ..., New]
                  // ListView (normal): Top [Old] ... Bottom [New]. current scroll at top? No.
                  // To stick to bottom, typically use reverse: true and order DESC (Newest first).
                  // Let's check DAO order.
                  // DAO: orderBy createdAt ASC. => [Oldest, ..., Newest].
                  // Normal ListView shows Oldest at top.
                  // We want to start at bottom.
                  // So we should maybe reverse the list in UI or change DAO or just use reverse: true with DESC order.
                  // Let's reverse the list locally for display if we use reverse: true.
                  // Reversed list: [Newest, ..., Oldest].
                  // ListView reverse: true => Bottom [Newest] ... Top [Oldest].
                  // This works for chat.
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final reversedIndex = comments.length - 1 - index;
                                        final commentWithUser = comments[reversedIndex];
                    // Encuentra el nombre del padre si existe
                    String? parentAuthorName;
                    if (commentWithUser.comment.parentId != null) {
                      final parent = comments.where((c) => c.comment.uuid == commentWithUser.comment.parentId).firstOrNull;
                      parentAuthorName = parent?.user.username;
                    }
                    return _CommentTile(
                      key: ValueKey(commentWithUser.comment.uuid),
                      comment: commentWithUser,
                      isMe: commentWithUser.comment.userRemoteId ==
                          ref.watch(activeUserProvider).value?.remoteId,
                      parentAuthorName: parentAuthorName,
                      onReply: () {
                        setState(() {
                          _replyTo = commentWithUser;
                        });
                        _focusNode.requestFocus();
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Error: $err')),
            ),
          ),
                    SafeArea(
            child: Column(
              children: [
                if (_replyTo != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.grey.shade200,
                    child: Row(
                      children: [
                        const Icon(Icons.reply, size: 16),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Respondiendo a ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () {
                            setState(() {
                              _replyTo = null;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, -1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isSpoiler ? Icons.visibility_off : Icons.visibility,
                          color: _isSpoiler ? Theme.of(context).primaryColor : Colors.grey,
                        ),
                        tooltip: 'Marcar como spoiler',
                        onPressed: () {
                          setState(() {
                            _isSpoiler = !_isSpoiler;
                          });
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: 'Escribe un comentario...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _isSending ? null : _sendComment,
                        icon: _isSending
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatefulWidget {
  const _CommentTile({
    super.key,
    required this.comment,
    required this.isMe,
    this.parentAuthorName,
    required this.onReply,
  });

  final CommentWithUser comment;
  final bool isMe;
  final String? parentAuthorName;
  final VoidCallback onReply;

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  bool _spoilerRevealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor =
        widget.isMe ? theme.primaryColor.withValues(alpha: 0.1) : Colors.white;
    final align = widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.circular(12);

    final isSpoiler = widget.comment.comment.isSpoiler;
    final contentHidden = isSpoiler && !_spoilerRevealed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: align,
        children: [
          GestureDetector(
            onLongPress: widget.onReply,
            onTap: () {
              if (contentHidden) {
                setState(() {
                  _spoilerRevealed = true;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              decoration: BoxDecoration(
                color: contentHidden ? Colors.grey.shade800 : bgColor,
                borderRadius: widget.isMe
                    ? radius.copyWith(bottomRight: Radius.zero)
                    : radius.copyWith(bottomLeft: Radius.zero),
                border: Border.all(color: contentHidden ? Colors.grey.shade900 : Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.parentAuthorName != null && !contentHidden) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.reply, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'A ',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (!widget.isMe && !contentHidden) ...[
                    Text(
                      widget.comment.user.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (contentHidden)
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility_off, color: Colors.white70, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Spoiler (toca para ver)',
                          style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                        ),
                      ],
                    )
                  else
                    Text(
                      widget.comment.comment.content,
                      style: const TextStyle(fontSize: 15),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  intl.DateFormat('dd MMM HH:mm', 'es')
                      .format(widget.comment.comment.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: widget.onReply,
                  child: Text(
                    'Responder',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
