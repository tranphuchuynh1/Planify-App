import 'package:flutter/material.dart';
import 'package:hoctapflutter/core/models/task_model.dart';
import '../../core/services/task_service.dart';
import '../home/main_page.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;

  const TaskDetailPage({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late Task _currentTask;
  bool _isLoading = false;
  bool _hasChanges = false; // Track if any changes were made

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  Color _getCategoryColor(String? category) {
    const categoryColors = {
      'Grocery': Color(0xFFCCFF80),
      'Work': Color(0xFFFF9680),
      'Sport': Color(0xFF80F5FF),
      'Design': Color(0xFF80FFD1),
      'University': Color(0xFF809CFF),
      'Social': Color(0xFFFF80EB),
      'Music': Color(0xFFFC80FF),
      'Health': Color(0xFF80FFA3),
      'Movie': Color(0xFF80D1FF),
      'Home': Color(0xFFFFD700),
    };
    return categoryColors[category] ?? const Color(0xFF8687E7);
  }

  IconData _getCategoryIcon(String? category) {
    const categoryIcons = {
      'Grocery': Icons.local_grocery_store,
      'Work': Icons.work_outline,
      'Sport': Icons.fitness_center,
      'Design': Icons.design_services,
      'University': Icons.school,
      'Social': Icons.people,
      'Music': Icons.music_note,
      'Health': Icons.favorite,
      'Movie': Icons.movie,
      'Home': Icons.home,
    };
    return categoryIcons[category] ?? Icons.task;
  }

  String _getPriorityText(int? priority) {
    if (priority == null) return 'Default';
    return priority.toString();
  }

  Color _getPriorityColor(int priority) {
    if (priority <= 2) return const Color(0xFFFF4757);
    if (priority <= 4) return const Color(0xFFFF6B35);
    if (priority <= 6) return const Color(0xFFFFA726);
    if (priority <= 8) return const Color(0xFF66BB6A);
    return const Color(0xFF42A5F5);
  }

  void _showSuccessNotification() {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF8875FF),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text(
                  'Edit successful!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove the notification sau 2 seconds hehe
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void _showDeleteNotification() {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF8875FF),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text(
                  'Task deleted successfully',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove the notification sau 2 seconds hehe
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void _showEditTitleDialog() {
    final TextEditingController titleController = TextEditingController(text: _currentTask.title);
    final TextEditingController descriptionController = TextEditingController(
        text: _currentTask.description ?? 'Do chapter 2 to 5 for next week'
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF363636),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Task',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),

                // Title input
                const Text(
                  'Title',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF121212),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF8687E7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF8687E7)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF8687E7), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),

                // Description input
                const Text(
                  'Description',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF121212),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF8687E7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF8687E7)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF8687E7), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    hintText: 'Enter task description...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ),
                const SizedBox(height: 30),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isNotEmpty) {
                          // Update both title and description
                          await _updateTaskTitleAndDescription(
                            titleController.text.trim(),
                            descriptionController.text.trim(),
                          );
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8687E7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateTaskTime(String date, String time) async {
    setState(() {
      _isLoading = true;
    });

    try {
      DateTime? parsedDate;
      try {
        parsedDate = DateTime.parse(date);
      } catch (e) {
        throw 'Invalid date format. Please use YYYY-MM-DD';
      }

      Task updatedTask = await TaskService.updateTask(
        taskId: _currentTask.id,
        taskDate: parsedDate,
        taskTime: time,
      );

      setState(() {
        _currentTask = updatedTask;
        _hasChanges = true;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task time: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showEditTimeDialog() {
    final TextEditingController dateController = TextEditingController(
        text: _currentTask.taskDate?.toString().substring(0, 10) ?? DateTime.now().toString().substring(0, 10)
    );
    final TextEditingController timeController = TextEditingController(
        text: _currentTask.taskTime ?? '00:00'
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF363636),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Task Time',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),

                // Date input
                const Text(
                  'Date (YYYY-MM-DD)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: dateController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF121212),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF8687E7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF8687E7)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF8687E7), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    hintText: 'YYYY-MM-DD',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ),
                const SizedBox(height: 16),

                // Time input
                const Text(
                  'Time (HH:MM)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: timeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF121212),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF8687E7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF8687E7)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF8687E7), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    hintText: 'HH:MM',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ),
                const SizedBox(height: 30),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await _updateTaskTime(
                          dateController.text.trim(),
                          timeController.text.trim(),
                        );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8687E7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCategoryDialog() {
    final categories = [
      {'name': 'Grocery', 'icon': Icons.local_grocery_store, 'color': const Color(0xFFCCFF80)},
      {'name': 'Work', 'icon': Icons.work_outline, 'color': const Color(0xFFFF9680)},
      {'name': 'Sport', 'icon': Icons.fitness_center, 'color': const Color(0xFF80F5FF)},
      {'name': 'Design', 'icon': Icons.design_services, 'color': const Color(0xFF80FFD1)},
      {'name': 'University', 'icon': Icons.school, 'color': const Color(0xFF809CFF)},
      {'name': 'Social', 'icon': Icons.people, 'color': const Color(0xFFFF80EB)},
      {'name': 'Music', 'icon': Icons.music_note, 'color': const Color(0xFFFC80FF)},
      {'name': 'Health', 'icon': Icons.favorite, 'color': const Color(0xFF80FFA3)},
      {'name': 'Movie', 'icon': Icons.movie, 'color': const Color(0xFF80D1FF)},
      {'name': 'Home', 'icon': Icons.home, 'color': const Color(0xFFFFD700)},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF363636),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Category',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: categories.map((category) {
                  final isSelected = _currentTask.category == category['name'];
                  return GestureDetector(
                    onTap: () async {
                      await _updateTaskField('category', category['name'] as String);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (category['color'] as Color)
                            : (category['color'] as Color).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            color: Colors.black,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category['name'] as String,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showPriorityDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF363636),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Task Priority',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    // Priority options 1-10
                    ...List.generate(10, (index) {
                      final priority = index + 1;
                      final isSelected = _currentTask.priority == priority;
                      return ListTile(
                        leading: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(priority),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.flag,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              priority.toString(),
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF8687E7) : Colors.white,
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              priority <= 2 ? 'High Priority' :
                              priority <= 4 ? 'Medium High' :
                              priority <= 6 ? 'Medium' :
                              priority <= 8 ? 'Medium Low' : 'Low Priority',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Color(0xFF8687E7))
                            : null,
                        onTap: () async {
                          await _updateTaskField('priority', priority);
                          Navigator.pop(context);
                        },
                      );
                    }),
                    // Default option
                    ListTile(
                      leading: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.flag,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            'Default',
                            style: TextStyle(
                              color: _currentTask.priority == null ? const Color(0xFF8687E7) : Colors.white,
                              fontSize: 16,
                              fontWeight: _currentTask.priority == null ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'No Priority',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      trailing: _currentTask.priority == null
                          ? const Icon(Icons.check, color: Color(0xFF8687E7))
                          : null,
                      onTap: () async {
                        await _updateTaskField('priority', null);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateTaskTitleAndDescription(String title, String description) async {
    setState(() {
      _isLoading = true;
    });

    try {
      Task updatedTask = await TaskService.updateTask(
        taskId: _currentTask.id,
        title: title,
        description: description,
      );

      setState(() {
        _currentTask = updatedTask;
        _hasChanges = true;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF363636),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Delete Task',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Are you sure you want to delete this task?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Task title : ${_currentTask.title}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _deleteTask();
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(true); // Close detail page and indicate changes
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8687E7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateTaskField(String field, dynamic value) async {
    setState(() {
      _isLoading = true;
    });

    try {
      Task updatedTask;
      switch (field) {
        case 'title':
          updatedTask = await TaskService.updateTask(
            taskId: _currentTask.id,
            title: value,
          );
          break;
        case 'category':
          updatedTask = await TaskService.updateTask(
            taskId: _currentTask.id,
            category: value,
          );
          break;
        case 'priority':
          updatedTask = await TaskService.updateTask(
            taskId: _currentTask.id,
            priority: value,
          );
          break;
        default:
          updatedTask = _currentTask;
      }

      setState(() {
        _currentTask = updatedTask;
        _hasChanges = true;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _deleteTask() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await TaskService.deleteTask(_currentTask.id);

      if (mounted) {
        _showDeleteNotification();

        await Future.delayed(const Duration(milliseconds: 500));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete task: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _formatTaskTime() {
    final now = DateTime.now();
    final taskDate = _currentTask.taskDate;

    if (taskDate == null) return 'Today At ${_currentTask.taskTime ?? '00:00'}';

    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDay = DateTime(taskDate.year, taskDate.month, taskDate.day);

    String dayLabel;
    if (taskDay.isAtSameMomentAs(today)) {
      dayLabel = 'Today';
    } else if (taskDay.isAtSameMomentAs(tomorrow)) {
      dayLabel = 'Tomorrow';
    } else {
      dayLabel = '${taskDate.day}/${taskDate.month}';
    }

    return '$dayLabel At ${_currentTask.taskTime ?? '00:00'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () {
            Navigator.of(context).pop(true); // Indicate changes were made
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.repeat,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              // Handle repeat functionality if needed
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8687E7),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Title Section
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _currentTask.isCompleted
                                ? const Color(0xFF8687E7)
                                : Colors.white.withOpacity(0.6),
                            width: 2,
                          ),
                          color: _currentTask.isCompleted
                              ? const Color(0xFF8687E7)
                              : Colors.transparent,
                        ),
                        child: _currentTask.isCompleted
                            ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _currentTask.title,
                          style: TextStyle(
                            color: _currentTask.isCompleted
                                ? Colors.white.withOpacity(0.6)
                                : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            decoration: _currentTask.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _showEditTitleDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Padding(
                    padding: const EdgeInsets.only(left: 36),
                    child: Text(
                      _currentTask.description ?? 'Do chapter 2 to 5 for next week',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Task Time Section
                  GestureDetector(
                    onTap: _showEditTimeDialog,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF363636),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Task Time :',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8687E7).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTaskTime(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Task Category Section
                  GestureDetector(
                    onTap: _showCategoryDialog,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF363636),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_offer,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Task Category :',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          if (_currentTask.category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(_currentTask.category),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getCategoryIcon(_currentTask.category),
                                    color: Colors.black,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _currentTask.category!,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'No Category',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Task Priority Section
                  GestureDetector(
                    onTap: _showPriorityDialog,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF363636),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.flag,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Task Priority :',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _currentTask.priority != null
                                  ? _getPriorityColor(_currentTask.priority!).withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getPriorityText(_currentTask.priority),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sub-Task Section (placeholder)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF363636),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.list,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Sub - Task',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8687E7).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Add Sub - Task',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Delete Task Button
                  GestureDetector(
                    onTap: _showDeleteConfirmDialog,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Delete Task',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Edit Task Button
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (_hasChanges) {
                    _showSuccessNotification();
                    // Navigate back to MainPage after showing notification
                    Future.delayed(const Duration(milliseconds: 500), () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainPage()),
                      );
                    });
                  } else {
                    // Show message if no changes were made
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No changes to save'),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8687E7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Edit Task',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}