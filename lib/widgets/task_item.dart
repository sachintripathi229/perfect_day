import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Task'),
            content: Text('Delete "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: GestureDetector(
              onTap: onToggle,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: task.isCompleted
                    ? Colors.green.shade400
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: task.isCompleted
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                    : const Icon(Icons.circle_outlined, color: Colors.grey, size: 18),
              ),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted
                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)
                    : null,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                task.isCompleted ? Icons.undo : Icons.check_box_outline_blank,
                color: task.isCompleted ? Colors.orange : Theme.of(context).colorScheme.primary,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ),
    );
  }
}
