import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_ticketing/features/auth/data/repositories/auth_repository.dart';
import 'package:e_ticketing/features/auth/data/models/user_model.dart';

// Provider untuk instance Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Provider untuk Auth Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

// Provider untuk memantau status sesi user (Login/Logout)
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

// Provider untuk mendapatkan current `User` dari Supabase (sesi saat ini)
final currentSupabaseUserProvider = Provider<User?>((ref) {
  return ref.watch(supabaseClientProvider).auth.currentUser;
});

// Provider untuk memuat `UserModel` (profile) dari tabel `profiles` berdasarkan sesi saat ini
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(currentSupabaseUserProvider);
  if (user == null) return null;

  final repo = ref.watch(authRepositoryProvider);
  return await repo.getUserProfile(user.id);
});
