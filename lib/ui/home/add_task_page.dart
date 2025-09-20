import 'package:flutter/material.dart';

import '../../core/services/task_service.dart';
import 'main_page.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedCategory;
  int? _selectedPriority;
  bool _isLoading = false;

  // Category data with colors matching the design
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Grocery', 'icon': Icons.cake, 'color': const Color(0xFFCCFF80)},
    {'name': 'Work', 'icon': Icons.work_outline, 'color': const Color(0xFFFF9680)},
    {'name': 'Sport', 'icon': Icons.fitness_center, 'color': const Color(0xFF80F5FF)},
    {'name': 'Design', 'icon': Icons.design_services, 'color': const Color(0xFF80FFD1)},
    {'name': 'University', 'icon': Icons.school, 'color': const Color(0xFF809CFF)},
    {'name': 'Social', 'icon': Icons.campaign, 'color': const Color(0xFFFF80EB)},
    {'name': 'Music', 'icon': Icons.music_note, 'color': const Color(0xFFFC80FF)},
    {'name': 'Health', 'icon': Icons.favorite, 'color': const Color(0xFF80FFA3)},
    {'name': 'Movie', 'icon': Icons.movie, 'color': const Color(0xFF80D1FF)},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Save task to Supabase
  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert TimeOfDay to string format (HH:mm)
      String? taskTimeString;
      if (_selectedTime != null) {
        final hour = _selectedTime!.hour.toString().padLeft(2, '0');
        final minute = _selectedTime!.minute.toString().padLeft(2, '0');
        taskTimeString = '$hour:$minute';
      }

      final task = await TaskService.createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        taskDate: _selectedDate,
        taskTime: taskTimeString,
        category: _selectedCategory,
        priority: _selectedPriority,
      );

      if (mounted) {
        _showSuccessNotification();

        // Chờ một chút để user thấy notification trước khi chuyển page
        await Future.delayed(const Duration(milliseconds: 500));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create task: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                  'Create new task successfully!',
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

    // Remove the notification sau 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  // using showDatePicker của Flutter
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8687E7),
              onPrimary: Colors.white,
              surface: Color(0xFF363636),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF363636),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // using showTimePicker
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8687E7),
              onPrimary: Colors.white,
              surface: Color(0xFF363636),
              onSurface: Colors.white,
              secondary: Color(0xFF8687E7),
            ),
            dialogBackgroundColor: const Color(0xFF363636),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFF363636),
              hourMinuteTextColor: Colors.white,
              dayPeriodTextColor: Colors.white,
              dialHandColor: const Color(0xFF8687E7),
              dialBackgroundColor: const Color(0xFF2D2D2D),
              entryModeIconColor: Colors.white,
              helpTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Hiển thị cả date picker và time picker liên tiếp
  Future<void> _showDateTimePicker() async {
    await _selectDate();
    if (_selectedDate != null) {
      await _selectTime();
    }
  }

  // Show Category Dialog
  Future<void> _showCategoryDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF363636),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Choose Category',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Fixed height container for the grid
                    SizedBox(
                      height: 280,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // First 9 items in rows of 3
                            for (int row = 0; row < 3; row++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    for (int col = 0; col < 3; col++)
                                      _buildCategoryItem(row * 3 + col),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8687E7),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(int index) {
    if (index >= _categories.length) {
      return const SizedBox(width: 70); // Empty space
    }

    final category = _categories[index];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category['name'];
        });
        Navigator.pop(context);
      },
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: category['color'],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                category['icon'],
                color: Colors.black,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Show Priority Dialog - Fix 2: Sửa cách truyền tempPriority
  Future<void> _showPriorityDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        int? tempPriority = _selectedPriority;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: const Color(0xFF363636),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  maxWidth: MediaQuery.of(context).size.width * 0.85,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Task Priority',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Priority grid
                        SizedBox(
                          height: 200,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Row 1: 1-4
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    for (int i = 1; i <= 4; i++)
                                      GestureDetector(
                                        onTap: () {
                                          setStateDialog(() {
                                            tempPriority = i;
                                          });
                                        },
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: tempPriority == i ? const Color(0xFF8687E7) : const Color(0xFF2D2D2D),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: tempPriority == i ? const Color(0xFF8687E7) : Colors.grey[600]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.flag,
                                                color: tempPriority == i ? Colors.white : Colors.grey[400],
                                                size: 18,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                i.toString(),
                                                style: TextStyle(
                                                  color: tempPriority == i ? Colors.white : Colors.grey[400],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Row 2: 5-8
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    for (int i = 5; i <= 8; i++)
                                      GestureDetector(
                                        onTap: () {
                                          setStateDialog(() {
                                            tempPriority = i;
                                          });
                                        },
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: tempPriority == i ? const Color(0xFF8687E7) : const Color(0xFF2D2D2D),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: tempPriority == i ? const Color(0xFF8687E7) : Colors.grey[600]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.flag,
                                                color: tempPriority == i ? Colors.white : Colors.grey[400],
                                                size: 18,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                i.toString(),
                                                style: TextStyle(
                                                  color: tempPriority == i ? Colors.white : Colors.grey[400],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Row 3: 9-10
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    for (int i in [9, 10])
                                      GestureDetector(
                                        onTap: () {
                                          setStateDialog(() {
                                            tempPriority = i;
                                          });
                                        },
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: tempPriority == i ? const Color(0xFF8687E7) : const Color(0xFF2D2D2D),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: tempPriority == i ? const Color(0xFF8687E7) : Colors.grey[600]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.flag,
                                                color: tempPriority == i ? Colors.white : Colors.grey[400],
                                                size: 18,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                i.toString(),
                                                style: TextStyle(
                                                  color: tempPriority == i ? Colors.white : Colors.grey[400],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 60),
                                    const SizedBox(width: 60),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedPriority = tempPriority;
                                  });
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8687E7),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Save',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      // Fix 2: Thêm resizeToAvoidBottomInset để tránh overflow
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Task',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          //  Wrap toàn bộ body trong SingleChildScrollView
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight - 24,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Input
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: 'Task title',
                      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8687E7)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description Label
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Description Input
                  TextField(
                    controller: _descriptionController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Add description...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8687E7)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),

                  const Expanded(child: SizedBox()), // Fix 2: Spacer flexible

                  // Show selected items
                  if (_selectedDate != null || _selectedTime != null || _selectedCategory != null || _selectedPriority != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16, top: 16),
                      child: Column(
                        children: [
                          // Date/Time
                          if (_selectedDate != null || _selectedTime != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.schedule,
                                    color: Color(0xFF8687E7),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _buildDateTimeText(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDate = null;
                                        _selectedTime = null;
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Category
                          if (_selectedCategory != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.sell,
                                    color: Color(0xFF8687E7),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedCategory!,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = null;
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Priority
                          if (_selectedPriority != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.flag,
                                    color: Color(0xFF8687E7),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Priority $_selectedPriority',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedPriority = null;
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                  // Bottom Actions
                  Row(
                    children: [
                      // Timer/Alarm Icon - Chọn cả ngày và giờ
                      IconButton(
                        onPressed: _showDateTimePicker,
                        icon: const Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: 28,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),

                      // Category Icon
                      IconButton(
                        onPressed: _showCategoryDialog,
                        icon: const Icon(
                          Icons.sell_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),

                      // Flag Icon
                      IconButton(
                        onPressed: _showPriorityDialog,
                        icon: const Icon(
                          Icons.flag_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),

                      const Spacer(),

                      // Send/Save Button
                      Container(
                        decoration: BoxDecoration(
                          color: _isLoading
                              ? const Color(0xFF8687E7).withOpacity(0.6)
                              : const Color(0xFF8687E7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: _isLoading ? null : _saveTask,
                          icon: _isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildDateTimeText() {
    String result = '';
    if (_selectedDate != null) {
      result += '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
    }
    if (_selectedTime != null) {
      if (_selectedDate != null) result += ' at ';
      result += _selectedTime!.format(context);
    }
    return result;
  }
}