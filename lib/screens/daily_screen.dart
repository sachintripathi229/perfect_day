import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/apple_health_ring.dart';
import '../widgets/task_item.dart';

class DailyScreen extends StatelessWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildDateHeader(context),
              const SizedBox(height: 24),
              _buildProgressSection(
                  context, provider.todayProgress, provider.todayTasks),
              const SizedBox(height: 24),
              _buildStatsRow(context, provider),
              const SizedBox(height: 24),
              _buildTaskList(provider.todayTasks, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateHeader(BuildContext context) {
    final now = DateTime.now();
    return Column(
      children: [
        Text(
          DateFormat('EEEE', Localizations.localeOf(context).toLanguageTag())
              .format(now),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat.yMMMMd().format(now),
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(
      BuildContext context, double progress, List<Task> tasks) {
    return Column(
      children: [
        const Text(
          "Today's Progress",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        AppleHealthRing(
          progress: progress,
          size: 340,
          strokeWidth: 22,
          progressColor: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        if (tasks.isNotEmpty)
          Text(
            progress >= 1.0 ? '🎉 Perfect Day Achieved!' : 'Keep going!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: progress >= 1.0
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          '${tasks.where((t) => t.isCompleted).length} / ${tasks.length} completed',
          style: TextStyle(
            fontSize: 14,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, TaskProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statChip(
          context: context,
          icon: Icons.list_rounded,
          value: '${provider.todayTasks.length}',
          label: 'Total',
          color: Colors.blue,
        ),
        _statChip(
          context: context,
          icon: Icons.check_circle_rounded,
          value: '${provider.completedToday.length}',
          label: 'Done',
          color: Colors.green,
        ),
        _statChip(
          context: context,
          icon: Icons.pending_actions_rounded,
          value:
              '${provider.todayTasks.length - provider.completedToday.length}',
          label: 'Pending',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _statChip({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, TaskProvider provider) {
    if (tasks.isEmpty) {
      return _emptyState('No tasks for today', 'Tap + to add your first task!');
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskItem(
          task: task,
          onToggle: () => provider.toggleTask(task.id),
          onDelete: () => provider.deleteTask(task.id),
        );
      },
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.emoji_events_rounded,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(title,
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
