import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/apple_health_ring.dart';
import '../widgets/task_item.dart';

class WeeklyScreen extends StatelessWidget {
  const WeeklyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final weekDays = _getWeekDays();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWeekHeader(context),
              const SizedBox(height: 24),
              _buildProgressSection(context, provider.weeklyProgress, provider.weeklyTasks),
              const SizedBox(height: 24),
              _buildDayGrid(context, weekDays, provider),
              const SizedBox(height: 24),
              _buildTaskList(provider.weeklyTasks, provider),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getWeekDays() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) {
      final day = startOfWeek.add(Duration(days: i));
      return {
        'date': day,
        'label': DateFormat.E().format(day),
        'day': day.day,
      };
    });
  }

  Widget _buildWeekHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          'This Week',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('MMM d – MMM d, y').format(
            DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)),
          ),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context, double progress, List<Task> tasks) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Weekly Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          AppleHealthRing(
            progress: progress,
            size: 300,
            strokeWidth: 18,
            progressColor: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          if (tasks.isNotEmpty)
            Text(
              '${(progress * 100).toInt()}% Complete',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            '${tasks.where((t) => t.isCompleted).length} / ${tasks.length} completed',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayGrid(BuildContext context, List<Map<String, dynamic>> weekDays, TaskProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Day by Day',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDays.map((day) {
            final dateObj = day['date'] as DateTime;
            final dateStr = DateFormat('yyyy-MM-dd').format(dateObj);
            final dayTasks = provider.tasks.where((t) => t.date == dateStr).toList();
            final completed = dayTasks.where((t) => t.isCompleted).length;
            final total = dayTasks.length;
            final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateStr;

            return SizedBox(
              width: 42,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isToday
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      day['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day['day']}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (total > 0)
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: completed == total
                          ? Colors.green
                          : completed > 0
                              ? Colors.orange
                              : Colors.grey.shade300,
                      child: Text(
                        '$completed/$total',
                        style: const TextStyle(fontSize: 8),
                      ),
                    )
                  else
                    Text('—', style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTaskList(List<Task> tasks, TaskProvider provider) {
    if (tasks.isEmpty) {
      return _emptyState('No tasks this week', 'Add tasks to any day to get started!');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Tasks (${tasks.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.separated(
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
        ),
      ],
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.weekend_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
