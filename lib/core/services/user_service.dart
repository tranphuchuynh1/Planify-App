import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/user_model.dart';

class UserService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Lấy profile của user hiện tại với fallback
  static Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      // Thử lấy từ Supabase trước xem có data hay k - neu k thi luu tren shared luon tạm trước cái
      try {
        final response = await _supabase
            .from('user_profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle(); // Sử dụng maybeSingle thay vì single

        if (response != null) {
          return UserProfile.fromJson(response);
        }
      } catch (e) {
        print('Failed to fetch from Supabase: $e');
      }

      // Nếu không có trong Supabase, tạo profile mới hoặc lấy từ SharedPreferences
      return await _createOrGetProfileFromLocal(user);

    } catch (e) {
      print('Error in getCurrentUserProfile: $e');
      return null;
    }
  }

  // Tạo profile mới hoặc lấy từ local
  static Future<UserProfile?> _createOrGetProfileFromLocal(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localProfileJson = prefs.getString('user_profile_${user.id}');

      if (localProfileJson != null) {
        final profileData = jsonDecode(localProfileJson);
        return UserProfile.fromJson(profileData);
      }

      // Tạo profile mới với thông tin từ auth metadata
      final profile = UserProfile(
        id: user.id,
        fullName: user.userMetadata?['full_name'] as String?,
        avatarUrl: null,
        bio: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Lưu vào local
      await _saveProfileToLocal(profile);

      return profile;
    } catch (e) {
      print('Error creating profile: $e');
      return null;
    }
  }

  // Lưu profile vào SharedPreferences
  static Future<void> _saveProfileToLocal(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = jsonEncode(profile.toJson());
      await prefs.setString('user_profile_${profile.id}', profileJson);
    } catch (e) {
      print('Failed to save profile to local: $e');
    }
  }

  // Cập nhật tên người dùng
  static Future<void> updateFullName(String newName) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Thử cập nhật trong Supabase
      try {
        await _supabase
            .from('user_profiles')
            .upsert({
          'id': user.id,
          'full_name': newName,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        print('Failed to update in Supabase: $e');
      }

      // Cập nhật auth metadata
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {'full_name': newName},
        ),
      );

      // Cập nhật local storage
      final currentProfile = await getCurrentUserProfile();
      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(
          fullName: newName,
          updatedAt: DateTime.now(),
        );
        await _saveProfileToLocal(updatedProfile);
      }
    } catch (e) {
      throw Exception('Failed to update name: $e');
    }
  }

  // Cập nhật mật khẩu
  static Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  // Upload và cập nhật avatar với fallback lưu base64
  static Future<String> uploadAvatar(File imageFile) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Thử upload lên Supabase Storage
      try {
        final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await _supabase.storage
            .from('avatars')
            .upload(fileName, imageFile);

        final avatarUrl = _supabase.storage
            .from('avatars')
            .getPublicUrl(fileName);

        // Cập nhật trong database
        await _supabase
            .from('user_profiles')
            .upsert({
          'id': user.id,
          'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Cập nhật local
        final currentProfile = await getCurrentUserProfile();
        if (currentProfile != null) {
          final updatedProfile = currentProfile.copyWith(
            avatarUrl: avatarUrl,
            updatedAt: DateTime.now(),
          );
          await _saveProfileToLocal(updatedProfile);
        }

        return avatarUrl;
      } catch (e) {
        print('Failed to upload to Supabase Storage: $e');

        // Fallback: Lưu ảnh dưới dạng base64 trong SharedPreferences
        return await _saveAvatarToLocal(imageFile, user.id);
      }
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  // Lưu avatar dưới dạng base64 vào local
  static Future<String> _saveAvatarToLocal(File imageFile, String userId) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      final prefs = await SharedPreferences.getInstance();

      // Lưu base64 string
      await prefs.setString('avatar_$userId', base64String);

      // Tạo local URL identifier
      final localAvatarUrl = 'local_avatar_$userId';

      // Cập nhật profile local
      final currentProfile = await getCurrentUserProfile();
      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(
          avatarUrl: localAvatarUrl,
          updatedAt: DateTime.now(),
        );
        await _saveProfileToLocal(updatedProfile);
      }

      return localAvatarUrl;
    } catch (e) {
      throw Exception('Failed to save avatar locally: $e');
    }
  }

  // Lấy avatar dưới dạng base64 từ local
  static Future<String?> getLocalAvatarBase64(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('avatar_$userId');
    } catch (e) {
      return null;
    }
  }

  // Kiểm tra xem avatar có phải local không
  static bool isLocalAvatar(String? avatarUrl) {
    return avatarUrl?.startsWith('local_avatar_') == true;
  }

  // Cập nhật bio
  static Future<void> updateBio(String newBio) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      try {
        await _supabase
            .from('user_profiles')
            .upsert({
          'id': user.id,
          'bio': newBio,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        print('Failed to update bio in Supabase: $e');
      }

      // Cập nhật local
      final currentProfile = await getCurrentUserProfile();
      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(
          bio: newBio,
          updatedAt: DateTime.now(),
        );
        await _saveProfileToLocal(updatedProfile);
      }
    } catch (e) {
      throw Exception('Failed to update bio: $e');
    }
  }

  // Lấy thông tin user từ auth
  static User? get currentUser => _supabase.auth.currentUser;

  static String? get currentUserEmail => currentUser?.email;

  static String? get currentUserName {
    final user = currentUser;
    if (user == null) return null;
    return user.userMetadata?['full_name'] as String?;
  }

  // Xóa avatar cũ khi upload avatar mới
  static Future<void> deleteOldAvatar(String oldAvatarUrl) async {
    try {
      if (oldAvatarUrl.isEmpty) return;

      // Nếu là local avatar, xóa khỏi SharedPreferences
      if (isLocalAvatar(oldAvatarUrl)) {
        final user = currentUser;
        if (user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('avatar_${user.id}');
        }
        return;
      }

      // Nếu là Supabase URL, xóa khỏi storage
      final fileName = oldAvatarUrl.split('/').last;
      await _supabase.storage
          .from('avatars')
          .remove([fileName]);
    } catch (e) {
      print('Failed to delete old avatar: $e');
    }
  }

  // Kiểm tra và tạo bucket avatars nếu chưa có
  static Future<void> ensureAvatarBucketExists() async {
    try {
      await _supabase.storage.createBucket(
        'avatars',
        const BucketOptions(public: true),
      );
    } catch (e) {
      print('Avatar bucket may already exist: $e');
    }
  }

  // Xóa tất cả data local khi logout
  static Future<void> clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = currentUser;
      if (user != null) {
        await prefs.remove('user_profile_${user.id}');
        await prefs.remove('avatar_${user.id}');
      }
    } catch (e) {
      print('Failed to clear local data: $e');
    }
  }
}