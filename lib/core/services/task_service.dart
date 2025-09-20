



import '../models/task_model.dart';
import 'supabase_service.dart';

class TaskService {
  static const String _tableName = 'tasks';

  // Create a new task
  static Future<Task> createTask({
    required String title,
    String? description,
    DateTime? taskDate,
    String? taskTime,
    String? category,
    int? priority,
  }) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final taskData = {
        'user_id': userId,
        'title': title,
        'description': description,
        'task_date': taskDate?.toIso8601String().split('T')[0], // Only date part (YYYY-MM-DD)
        'task_time': taskTime, // Format: "HH:mm"
        'category': category,
        'priority': priority,
        'is_completed': false,
      };

      final response = await SupabaseService.client
          .from(_tableName)
          .insert(taskData)
          .select()
          .single();

      return Task.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  // Get all tasks for current user
  static Future<List<Task>> getAllTasks() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map<Task>((task) => Task.fromJson(task)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  // Get tasks for today
  static Future<List<Task>> getTodayTasks() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('task_date', today)
          .order('task_time', ascending: true);

      return response.map<Task>((task) => Task.fromJson(task)).toList();
    } catch (e) {
      throw Exception('Failed to fetch today tasks: $e');
    }
  }

  // Get completed tasks
  static Future<List<Task>> getCompletedTasks() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_completed', true)
          .order('updated_at', ascending: false);

      return response.map<Task>((task) => Task.fromJson(task)).toList();
    } catch (e) {
      throw Exception('Failed to fetch completed tasks: $e');
    }
  }

  // Update task completion status
  static Future<Task> toggleTaskCompletion(String taskId) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // First get the current task
      final currentTask = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('id', taskId)
          .eq('user_id', userId)
          .single();

      // Toggle completion status
      final newStatus = !currentTask['is_completed'];

      final response = await SupabaseService.client
          .from(_tableName)
          .update({
        'is_completed': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', taskId)
          .eq('user_id', userId)
          .select()
          .single();

      return Task.fromJson(response);
    } catch (e) {
      throw Exception('Failed to toggle task completion: $e');
    }
  }

  // Update task
  static Future<Task> updateTask({
    required String taskId,
    String? title,
    String? description,
    DateTime? taskDate,
    String? taskTime,
    String? category,
    int? priority,
    bool? isCompleted,
  }) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (taskDate != null) {
        updateData['task_date'] = taskDate.toIso8601String().split('T')[0];
      }
      if (taskTime != null) updateData['task_time'] = taskTime;
      if (category != null) updateData['category'] = category;
      if (priority != null) updateData['priority'] = priority;
      if (isCompleted != null) updateData['is_completed'] = isCompleted;

      final response = await SupabaseService.client
          .from(_tableName)
          .update(updateData)
          .eq('id', taskId)
          .eq('user_id', userId)
          .select()
          .single();

      return Task.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Delete task
  static Future<void> deleteTask(String taskId) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await SupabaseService.client
          .from(_tableName)
          .delete()
          .eq('id', taskId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Get task statistics
  static Future<Map<String, int>> getTaskStats() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final allTasks = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('user_id', userId);

      int totalTasks = allTasks.length;
      int completedTasks = allTasks.where((task) => task['is_completed'] == true).length;
      int pendingTasks = totalTasks - completedTasks;

      return {
        'total': totalTasks,
        'completed': completedTasks,
        'pending': pendingTasks,
      };
    } catch (e) {
      throw Exception('Failed to get task statistics: $e');
    }
  }

  // Get tasks by category
  static Future<List<Task>> getTasksByCategory(String category) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('category', category)
          .order('created_at', ascending: false);

      return response.map<Task>((task) => Task.fromJson(task)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks by category: $e');
    }
  }

  // Get tasks by priority
  static Future<List<Task>> getTasksByPriority(int priority) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('priority', priority)
          .order('created_at', ascending: false);

      return response.map<Task>((task) => Task.fromJson(task)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks by priority: $e');
    }
  }
}