import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/apple_health_ring.dart';
import '../widgets/task_item.dart';

class MonthlyScreen extends StatelessWidget {
  const MonthlyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final daysInMonth = _getDaysInMonth();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthHeader(context),
              const SizedBox(height: 24),
              _buildProgressSection(context, provider.monthlyProgress, provider.monthlyTasks),
              const SizedBox(height: 24),
              _buildCalendarGrid(context, daysInMonth, provider),
              const SizedBox(height: 24),
              _buildTaskList(provider.monthlyTasks, provider),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getDaysInMonth() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final days = <Map<String, dynamic>>[];

    for (int i = 0; i < firstDay.weekday % 7; i++) {
      days.add({'date': null, 'label': '', 'day': ''});
    }

    for (int d = 1; d <= lastDay.day; d++) {
      final date = DateTime(now.year, now.month, d);
      days.add({
        'date': date,
        'label': DateFormat.E().format(date),
        'day': d,
      });
    }

    return days;
  }

  Widget _buildMonthHeader(BuildContext context) {
    final now = DateTime.now();
    return Column(
      children: [
        Text(
          DateFormat('MMMM y').format(now),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
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
            Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Monthly Progress',
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

  Widget _buildCalendarGrid(
    BuildContext context,
    List<Map<String, dynamic>> days,
    TaskProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Month View',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(child: Center(child: Text('Su', style: TextStyle(fontSize: 12, color: Colors.grey)))),
            Expanded(child: Center(child: Text('Mo', style: TextStyle(fontSize: 12, color: Colors.grey)))),
            Expanded(child: Center(child: Text('Tu', style: TextStyle(fontSize: 12, color: Colors.grey)))),
            Expanded(child: Center(child: Text('We', style: TextStyle(fontSize: 12, color: Colors.grey)))),
            Expanded(child: Center(child: Text('Th', style: TextStyle(fontSize: 12, color: Colors.grey)))),
            Expanded(child: Center(child: Text('Fr', style: TextStyle(fontSize: 12, color: Colors.grey)))),
            Expanded(child: Center(child: Text('Sa', style: TextStyle(fontSize: 12, color: Colors.grey)))),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final dateObj = day['date'] as DateTime?;
            if (dateObj == null) {
              return const SizedBox();
            }
            final dateStr = DateFormat('yyyy-MM-dd').format(dateObj);
            final dayTasks = provider.tasks.where((t) => t.date == dateStr).toList();
            final completed = dayTasks.where((t) => t.isCompleted).length;
            final total = dayTasks.length;
            final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateStr;
            final isWeekend = dateObj.weekday == 7 || dateObj.weekday == 6;

            return Container(
              decoration: BoxDecoration(
                color: isToday
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                    : isWeekend
                        ? Colors.grey.shade100
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isToday
                    ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day['day']}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (total > 0)
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: completed == total
                          ? Colors.green
                          : completed > 0
                              ? Colors.orange
                              : Colors.grey.shade300,
                      child: Text(
                        '$completed/$total',
                        style: const TextStyle(fontSize: 7),
                      ),
                    )
                  else ...[
                    Text(
                      '—',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 8),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTaskList(List<Task> tasks, TaskProvider provider) {
    if (tasks.isEmpty) {
      return _emptyState('No tasks this month', 'Add tasks to fill your month!');
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
              onDismissed: (_) => provider.deleteTask(task.id),
              child: TaskItem(
                task: task,
                onToggle: () => provider.toggleTask(task.id),
                onDelete: () => provider.deleteTask(task.id),
              ),
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
          Icon(Icons.calendar_month_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
