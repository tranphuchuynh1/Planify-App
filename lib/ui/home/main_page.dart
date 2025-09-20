import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hoctapflutter/core/models/task_model.dart';
import 'package:hoctapflutter/ui/focus/focus_page.dart';
import 'package:hoctapflutter/ui/profile/profile_page.dart';

import '../../core/models/user_model.dart';
import '../../core/services/task_service.dart';
import '../../core/services/user_service.dart';
import '../calendar/calendar_page.dart';
import '../task_detail/task_detail_page.dart';
import 'add_task_page.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Widget> _pages = [];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pages = [
      const IndexPage(), // Home page
      const CalendarPage(),
      Container(), // Empty for FAB
      const FocusPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      resizeToAvoidBottomInset: false,
      body: _pages.elementAt(_currentPage),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF363636),
        unselectedItemColor: Colors.white,
        selectedItemColor: const Color(0xFF8687E7),
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentPage,
        onTap: (index) {
          if (index == 2) {
            return;
          }
          setState(() {
            _currentPage = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/home.png",
                width: 24, height: 24, fit: BoxFit.fill,
              ),
              activeIcon: Image.asset("assets/images/home.png",
                width: 24, height: 24, fit: BoxFit.fill, color: const Color(0xFF8687E7),
              ),
              label: "Home",
              backgroundColor: Colors.transparent
          ),
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/calendar.png",
                width: 24, height: 24, fit: BoxFit.fill,
              ),
              activeIcon: Image.asset("assets/images/calendar.png",
                width: 24, height: 24, fit: BoxFit.fill, color: const Color(0xFF8687E7),
              ),
              label: "Calendar",
              backgroundColor: Colors.transparent
          ),
          BottomNavigationBarItem(
              icon: Container(),
              label: "",
              backgroundColor: Colors.transparent
          ),
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/clock.png",
                width: 24, height: 24, fit: BoxFit.fill,
              ),
              activeIcon: Image.asset("assets/images/clock.png",
                width: 24, height: 24, fit: BoxFit.fill, color: const Color(0xFF8687E7),
              ),
              label: "Focuse",
              backgroundColor: Colors.transparent
          ),
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/user.png",
                width: 24, height: 24, fit: BoxFit.fill,
              ),
              activeIcon: Image.asset("assets/images/user.png",
                width: 24, height: 24, fit: BoxFit.fill, color: const Color(0xFF8687E7),
              ),
              label: "Profile",
              backgroundColor: Colors.transparent
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF8687E7),
          borderRadius: BorderRadius.circular(32),
        ),
        child: IconButton(
            onPressed: _navigateToAddTask,
            icon: const Icon(
              Icons.add,
              size: 30,
              color: Colors.white,
            )
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _navigateToAddTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskPage(),
      ),
    );

    if (result != null) {
      // Refresh the current page if it's IndexPage
      if (_currentPage == 0) {
        setState(() {
          _pages[0] = IndexPage(key: UniqueKey()); // Force rebuild with new key
        });
      }
    }
  }
}

// Updated Index Page with Avatar Display
class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  List<Task> _allTasks = [];
  List<Task> _todayTasks = [];
  List<Task> _completedTasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = true;
  String _filter = 'Today';
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _completingTasks = <String>{};

  // Avatar related states
  UserProfile? _userProfile;
  Uint8List? _localAvatarBytes;
  bool _isLoadingAvatar = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadUserAvatar();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAvatar() async {
    try {
      final profile = await UserService.getCurrentUserProfile();
      setState(() {
        _userProfile = profile;
      });

      // Load local avatar if exists
      if (profile?.hasAvatar == true && UserService.isLocalAvatar(profile!.avatarUrl!)) {
        final user = UserService.currentUser;
        if (user != null) {
          final base64String = await UserService.getLocalAvatarBase64(user.id);
          if (base64String != null) {
            setState(() {
              _localAvatarBytes = base64Decode(base64String);
            });
          }
        }
      }

      setState(() {
        _isLoadingAvatar = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAvatar = false;
      });
    }
  }

  Widget _buildAvatarWidget() {
    if (_isLoadingAvatar) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[800],
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_localAvatarBytes != null) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: MemoryImage(_localAvatarBytes!),
      );
    }

    if (_userProfile?.hasAvatar == true && !UserService.isLocalAvatar(_userProfile!.avatarUrl!)) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(_userProfile!.avatarUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          // Fallback to default avatar
        },
      );
    }

    // Default avatar
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey[800],
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    final baseTasks = _getFilteredTasks();

    if (query.isEmpty) {
      setState(() {
        _filteredTasks = baseTasks;
      });
    } else {
      setState(() {
        _filteredTasks = baseTasks.where((task) =>
        task.title.toLowerCase().contains(query) ||
            (task.description?.toLowerCase().contains(query) ?? false) ||
            (task.category?.toLowerCase().contains(query) ?? false)
        ).toList();
      });
    }
  }

  Future<void> _loadTasks() async {
    try {
      final allTasks = await TaskService.getAllTasks();
      final today = DateTime.now();

      final completedTasks = allTasks.where((task) => task.isCompleted).toList();
      final nonCompletedTasks = allTasks.where((task) => !task.isCompleted).toList();

      final todayTasks = nonCompletedTasks.where((task) {
        if (task.taskDate == null) return false;
        return task.taskDate!.year == today.year &&
            task.taskDate!.month == today.month &&
            task.taskDate!.day == today.day;
      }).toList();

      setState(() {
        _allTasks = allTasks;
        _todayTasks = todayTasks;
        _completedTasks = completedTasks;
        _isLoading = false;
      });

      _onSearchChanged();
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

  // Navigate to task detail
  void _navigateToTaskDetail(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(task: task),
      ),
    );

    // Refresh tasks if any changes were made
    if (result == true) {
      await _loadTasks();
    }
  }

  List<Task> _getFilteredTasks() {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final weekFromNow = today.add(const Duration(days: 7));

    List<Task> tasks;
    switch (_filter) {
      case 'Today':
        tasks = _todayTasks;
        break;

      case 'Tomorrow':
        final nonCompletedTasks = _allTasks.where((task) => !task.isCompleted).toList();
        tasks = nonCompletedTasks.where((task) {
          if (task.taskDate == null) return false;
          return task.taskDate!.year == tomorrow.year &&
              task.taskDate!.month == tomorrow.month &&
              task.taskDate!.day == tomorrow.day;
        }).toList();
        break;

      case 'This Week':
        final nonCompletedTasks = _allTasks.where((task) => !task.isCompleted).toList();
        tasks = nonCompletedTasks.where((task) {
          if (task.taskDate == null) return false;
          return task.taskDate!.isAfter(today.subtract(const Duration(days: 1))) &&
              task.taskDate!.isBefore(weekFromNow);
        }).toList();
        break;

      case 'Completed':
        tasks = _completedTasks;
        break;

      case 'All':
        tasks = _allTasks;
        break;

      default:
        tasks = _todayTasks;
        break;
    }

    tasks.sort((a, b) {
      if (_filter != 'Completed') {
        if (a.isCompleted && !b.isCompleted) return 1;
        if (!a.isCompleted && b.isCompleted) return -1;
      }

      final aPriority = a.priority ?? 999;
      final bPriority = b.priority ?? 999;

      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }

      return b.createdAt.compareTo(a.createdAt);
    });

    return tasks;
  }

  void _showFilterDropdown() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF363636),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter Tasks',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              ...[
                'Today',
                'Tomorrow',
                'This Week',
                'Completed',
                'All'
              ].map((filter) => ListTile(
                leading: Icon(
                  _getFilterIcon(filter),
                  color: _filter == filter ? const Color(0xFF8687E7) : Colors.white,
                ),
                title: Text(
                  filter,
                  style: TextStyle(
                    color: _filter == filter ? const Color(0xFF8687E7) : Colors.white,
                    fontWeight: _filter == filter ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                trailing: _filter == filter
                    ? const Icon(Icons.check, color: Color(0xFF8687E7))
                    : null,
                onTap: () {
                  setState(() {
                    _filter = filter;
                  });
                  Navigator.pop(context);
                  _onSearchChanged();
                },
              )),
            ],
          ),
        );
      },
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'Today':
        return Icons.today;
      case 'Tomorrow':
        return Icons.event;
      case 'This Week':
        return Icons.date_range;
      case 'Completed':
        return Icons.check_circle;
      case 'All':
        return Icons.list;
      default:
        return Icons.today;
    }
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

  String _formatTaskTime(Task task) {
    final now = DateTime.now();
    final taskDate = task.taskDate;

    if (taskDate == null) return 'Today At ${task.taskTime}';

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

    return '$dayLabel At ${task.taskTime}';
  }

  @override
  Widget build(BuildContext context) {
    final List<Task> displayTasks = _searchController.text.isEmpty
        ? _getFilteredTasks()
        : _filteredTasks;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.sort,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () {
            // Open drawer or menu
          },
        ),
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildAvatarWidget(),
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
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for your task...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withOpacity(0.6),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
                filled: true,
                fillColor: const Color(0xFF363636),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Filter dropdown button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showFilterDropdown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8687E7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _filter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (_searchController.text.isNotEmpty)
                  Text(
                    '${displayTasks.length} result${displayTasks.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tasks List
          Expanded(
            child: displayTasks.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _loadTasks,
              color: const Color(0xFF8687E7),
              backgroundColor: const Color(0xFF363636),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: displayTasks.length,
                itemBuilder: (context, index) {
                  final task = displayTasks[index];
                  return _buildTaskItem(task);
                },
              ),
            ),
          ),
        ],
      ),
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
                  // Title
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

                  // Time display
                  if (task.taskTime != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _formatTaskTime(task),
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
                // Priority
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

                // Category
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: 20,
                          top: 30,
                          child: Container(
                            width: 120,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 40,
                          top: 20,
                          child: Container(
                            width: 120,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.check_box,
                                          color: Colors.grey[400], size: 16),
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 60,
                                        height: 2,
                                        color: Colors.grey[300],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.check_box,
                                          color: Colors.grey[400], size: 16),
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 50,
                                        height: 2,
                                        color: Colors.grey[300],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.check_box_outline_blank,
                                          color: Colors.grey[400], size: 16),
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 45,
                                        height: 2,
                                        color: Colors.grey[300],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.check_box_outline_blank,
                                          color: Colors.grey[400], size: 16),
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 55,
                                        height: 2,
                                        color: Colors.grey[300],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 10,
                          bottom: 20,
                          child: Container(
                            width: 80,
                            height: 100,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 20,
                                  bottom: 0,
                                  child: Container(
                                    width: 40,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 25,
                                  top: 10,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF8687E7),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  Text(
                    _searchController.text.isNotEmpty
                        ? 'No tasks found for "${_searchController.text}"'
                        : _filter == 'Today'
                        ? 'What do you want to do today?'
                        : _filter == 'Tomorrow'
                        ? 'No tasks for tomorrow yet'
                        : _filter == 'This Week'
                        ? 'No tasks for this week yet'
                        : _filter == 'Completed'
                        ? 'No completed tasks yet'
                        : 'No tasks found',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  Text(
                    _searchController.text.isNotEmpty
                        ? 'Try a different search term'
                        : _filter == 'Today'
                        ? 'Tap + to add your tasks'
                        : _filter == 'Completed'
                        ? 'Complete some tasks to see them here'
                        : 'Try adding some tasks',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}