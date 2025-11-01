import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/gif_viewmodel.dart';
import '../../models/reaction_model.dart';

class CommentsDialog extends StatefulWidget {
  final GifViewModel gifViewModel;
  final Function(String) onAddComment;
  final Function(String) onRemoveComment;

  const CommentsDialog({
    super.key,
    required this.gifViewModel,
    required this.onAddComment,
    required this.onRemoveComment,
  });

  @override
  State<CommentsDialog> createState() => _CommentsDialogState();
}

class _CommentsDialogState extends State<CommentsDialog> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comments = widget.gifViewModel.commentsForCurrentGif;
    final reactions = widget.gifViewModel.reactionsForCurrentGif;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Comentários e Reações',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // Reactions
            if (reactions.isNotEmpty) ...[
              Text('Reações:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: reactions.map((r) => Chip(
                  label: Text(ReactionModel.getReactionEmoji(r.reactionType)),
                  backgroundColor: r.user == widget.gifViewModel.currentUser 
                      ? Colors.blue.shade100 
                      : null,
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],
            
            // Comments
            Expanded(
              child: comments.isEmpty
                  ? const Center(child: Text('Nenhum comentário ainda.'))
                  : ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(comment.text),
                            subtitle: Text(
                              '${comment.author} • ${DateFormat('dd/MM/yyyy HH:mm').format(comment.timestamp)}',
                            ),
                            trailing: comment.author == widget.gifViewModel.currentUser
                                ? IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      widget.onRemoveComment(comment.id);
                                      Navigator.of(context).pop();
                                      // Reopen dialog to refresh
                                      Future.delayed(const Duration(milliseconds: 100), () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => CommentsDialog(
                                            gifViewModel: widget.gifViewModel,
                                            onAddComment: widget.onAddComment,
                                            onRemoveComment: widget.onRemoveComment,
                                          ),
                                        );
                                      });
                                    },
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
            
            // Add comment field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Adicionar comentário...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        widget.onAddComment(text);
                        _commentController.clear();
                        Navigator.of(context).pop();
                        // Reopen dialog to refresh
                        Future.delayed(const Duration(milliseconds: 100), () {
                          showDialog(
                            context: context,
                            builder: (context) => CommentsDialog(
                              gifViewModel: widget.gifViewModel,
                              onAddComment: widget.onAddComment,
                              onRemoveComment: widget.onRemoveComment,
                            ),
                          );
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final text = _commentController.text.trim();
                    if (text.isNotEmpty) {
                      widget.onAddComment(text);
                      _commentController.clear();
                      Navigator.of(context).pop();
                      // Reopen dialog to refresh
                      Future.delayed(const Duration(milliseconds: 100), () {
                        showDialog(
                          context: context,
                          builder: (context) => CommentsDialog(
                            gifViewModel: widget.gifViewModel,
                            onAddComment: widget.onAddComment,
                            onRemoveComment: widget.onRemoveComment,
                          ),
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
