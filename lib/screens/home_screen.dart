import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'daily_screen.dart';
import 'weekly_screen.dart';
import 'monthly_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _pageController = PageController();

  final List<Widget> _pages = const [
    DailyScreen(),
    WeeklyScreen(),
    MonthlyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfect Day',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: _clearAllCompleted,
            tooltip: 'Clear completed',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: _showAddTaskDialog,
              tooltip: 'Add Task',
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_rounded),
            selectedIcon: Icon(Icons.today),
            label: 'Daily',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_rounded),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Weekly',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_rounded),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Monthly',
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'What needs to be done?',
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _addTask(controller.text, ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _addTask(controller.text, ctx),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addTask(String title, BuildContext ctx) {
    if (title.trim().isEmpty) return;
    Provider.of<TaskProvider>(ctx, listen: false).addTask(Task(title: title.trim()));
    Navigator.pop(ctx);
  }

  void _clearAllCompleted() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Completed'),
        content: const Text('Remove all completed tasks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<TaskProvider>(ctx, listen: false);
              provider.tasks.where((t) => t.isCompleted).toList().forEach((t) {
                provider.deleteTask(t.id);
              });
              Navigator.pop(ctx);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
