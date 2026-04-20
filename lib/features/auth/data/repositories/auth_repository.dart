import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  // Fungsi Login
  Future<AuthResponse> login(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Fungsi Mengambil Data Profil (termasuk Role)
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      return null;
    }
  }

  // Fungsi Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
