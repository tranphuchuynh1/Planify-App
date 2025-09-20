import 'package:flutter/material.dart';
import 'package:hoctapflutter/core/models/task_model.dart';
import 'package:hoctapflutter/core/services/task_service.dart';
import '../task_detail/task_detail_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _currentDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  List<Task> _allTasks = [];
  List<Task> _selectedDateTasks = [];
  bool _isLoading = true;
  bool _showCompleted = false;
  final Set<String> _completingTasks = <String>{};

  // Calendar related variables
  late DateTime _displayedMonth;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(_currentDate.year, _currentDate.month);
    _pageController = PageController(initialPage: 0);
    _loadTasks();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    try {
      final allTasks = await TaskService.getAllTasks();
      setState(() {
        _allTasks = allTasks;
        _isLoading = false;
      });
      _updateSelectedDateTasks();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load tasks: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateSelectedDateTasks() {
    final tasksForSelectedDate = _allTasks.where((task) {
      if (task.taskDate == null) return false;
      return task.taskDate!.year == _selectedDate.year &&
          task.taskDate!.month == _selectedDate.month &&
          task.taskDate!.day == _selectedDate.day;
    }).toList();

    List<Task> filteredTasks;
    if (_showCompleted) {
      filteredTasks = tasksForSelectedDate.where((task) => task.isCompleted).toList();
    } else {
      filteredTasks = tasksForSelectedDate.where((task) => !task.isCompleted).toList();
    }

    // Sort tasks
    filteredTasks.sort((a, b) {
      final aPriority = a.priority ?? 999;
      final bPriority = b.priority ?? 999;
      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    setState(() {
      _selectedDateTasks = filteredTasks;
    });
  }

  bool _hasTasksOnDate(DateTime date) {
    return _allTasks.any((task) =>
    task.taskDate != null &&
        task.taskDate!.year == date.year &&
        task.taskDate!.month == date.month &&
        task.taskDate!.day == date.day);
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _updateSelectedDateTasks();
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _toggleTaskCompletion(String taskId) async {
    setState(() {
      _completingTasks.add(taskId);
    });

    try {
      await TaskService.toggleTaskCompletion(taskId);
      await Future.delayed(const Duration(milliseconds: 1500));
      await _loadTasks();

      setState(() {
        _completingTasks.remove(taskId);
      });
    } catch (e) {
      setState(() {
        _completingTasks.remove(taskId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToTaskDetail(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(task: task),
      ),
    );

    if (result == true) {
      await _loadTasks();
    }
  }

  String _getMonthName(int month) {
    const months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    return months[month - 1];
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
      'Home': Color(0xFFFF9680),
    };
    return categoryColors[category] ?? const Color(0xFF8687E7);
  }

  IconData _getCategoryIcon(String? category) {
    const categoryIcons = {
      'Grocery': Icons.cake,
      'Work': Icons.work_outline,
      'Sport': Icons.fitness_center,
      'Design': Icons.design_services,
      'University': Icons.school,
      'Social': Icons.campaign,
      'Music': Icons.music_note,
      'Health': Icons.favorite,
      'Movie': Icons.movie,
      'Home': Icons.home,
    };
    return categoryIcons[category] ?? Icons.task;
  }

  Color _getPriorityColor(int priority) {
    if (priority <= 2) return const Color(0xFFFF4757);
    if (priority <= 4) return const Color(0xFFFF6B35);
    if (priority <= 6) return const Color(0xFFFFA726);
    if (priority <= 8) return const Color(0xFF66BB6A);
    return const Color(0xFF42A5F5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8687E7),
        ),
      )
          : Column(
        children: [
          // Calendar Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      _getMonthName(_displayedMonth.month),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      _displayedMonth.year.toString(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),

          // Weekday Headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                  .map((day) => SizedBox(
                width: 40,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: day == 'SUN' || day == 'SAT'
                        ? const Color(0xFFFF4757)
                        : Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ))
                  .toList(),
            ),
          ),

          // Calendar Grid
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCalendarGrid(),
          ),

          const SizedBox(height: 12),

          // Today/Completed Toggle
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showCompleted = false;
                      });
                      _updateSelectedDateTasks();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_showCompleted
                            ? const Color(0xFF8687E7)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF8687E7),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Today',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !_showCompleted
                              ? Colors.white
                              : const Color(0xFF8687E7),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showCompleted = true;
                      });
                      _updateSelectedDateTasks();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _showCompleted
                            ? const Color(0xFF8687E7)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF8687E7),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Completed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _showCompleted
                              ? Colors.white
                              : const Color(0xFF8687E7),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tasks List
          Expanded(
            child: _selectedDateTasks.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _loadTasks,
              color: const Color(0xFF8687E7),
              backgroundColor: const Color(0xFF363636),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _selectedDateTasks.length,
                itemBuilder: (context, index) {
                  final task = _selectedDateTasks[index];
                  return _buildTaskItem(task);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday % 7; // Make Sunday = 0
    final daysInMonth = lastDayOfMonth.day;
    final totalCells = firstDayWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final itemCount = rows * 7; // 6 weeks * 7 days

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: itemCount,

      itemBuilder: (context, index) {
        final dayIndex = index - firstDayWeekday;

        if (dayIndex < 0 || dayIndex >= daysInMonth) {
          return const SizedBox(); // Empty cell
        }

        final day = dayIndex + 1;
        final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
        final isSelected = date.year == _selectedDate.year &&
            date.month == _selectedDate.month &&
            date.day == _selectedDate.day;
        final isToday = date.year == _currentDate.year &&
            date.month == _currentDate.month &&
            date.day == _currentDate.day;
        final hasTask = _hasTasksOnDate(date);

        final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

        return GestureDetector(
          onTap: () => _onDateSelected(date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8687E7) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isToday && !isSelected
                  ? Border.all(color: const Color(0xFF8687E7), width: 1)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isWeekend
                        ? const Color(0xFFFF4757)
                        : Colors.white,
                    fontSize: 16,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (hasTask && !isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF8687E7),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskItem(Task task) {
    final isCompleting = _completingTasks.contains(task.id);
    final showAsCompleted = task.isCompleted || isCompleting;

    return GestureDetector(
      onTap: () => _navigateToTaskDetail(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF363636),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: isCompleting ? null : () => _toggleTaskCompletion(task.id),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: showAsCompleted ? const Color(0xFF8687E7) : Colors.white.withOpacity(0.6),
                    width: 2,
                  ),
                  color: showAsCompleted ? const Color(0xFF8687E7) : Colors.transparent,
                ),
                child: showAsCompleted
                    ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                )
                    : null,
              ),
            ),

            const SizedBox(width: 16),

            // Task content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: showAsCompleted
                          ? Colors.white.withOpacity(0.6)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: showAsCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.taskTime != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Today At ${task.taskTime}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                          decoration: showAsCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Category and Priority
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (task.priority != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task.priority!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.flag,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          task.priority.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (task.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(task.category),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(task.category),
                          color: Colors.black,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.category!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showCompleted ? Icons.check_circle_outline : Icons.event_note,
            color: Colors.white.withOpacity(0.3),
            size: 80,
          ),
          const SizedBox(height: 20),
          Text(
            _showCompleted
                ? 'No completed tasks'
                : 'No tasks for this day',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showCompleted
                ? 'Complete some tasks to see them here'
                : 'Tap + to add tasks for this day',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}