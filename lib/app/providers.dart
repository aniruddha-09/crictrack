// lib/app/providers.dart
// Global Riverpod providers for repository, auth state, and user profile.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/cricket_repository.dart';
import '../data/mock/mock_cricket_repository.dart';
import '../data/models/user_profile.dart';
import '../data/models/enums.dart';
import '../data/models/session.dart';
import '../data/mock/mock_data_generator.dart';

// ─── Repository Provider ──────────────────────────────────────────────────────
// TODO(backend): Switch MockCricketRepository → RealCricketRepository
final cricketRepositoryProvider = Provider<CricketRepository>(
  (ref) => MockCricketRepository(),
);

// ─── Auth State ───────────────────────────────────────────────────────────────
class AuthState {
  final bool isLoggedIn;
  final UserProfile? user;

  const AuthState({this.isLoggedIn = false, this.user});

  AuthState copyWith({bool? isLoggedIn, UserProfile? user}) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final CricketRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState());

  Future<void> login(String phone, UserRole role) async {
    final profile = MockDataGenerator.generateUserProfile(phone, role);
    await _repo.setCurrentUser(profile);
    state = AuthState(isLoggedIn: true, user: profile);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }

  void updateRole(UserRole role) {
    if (state.user != null) {
      state = state.copyWith(user: state.user!.copyWith(role: role));
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(cricketRepositoryProvider)),
);

// ─── Sessions Provider ────────────────────────────────────────────────────────
final sessionsProvider = FutureProvider<List<CricketSession>>(
  (ref) => ref.read(cricketRepositoryProvider).getSessions(),
);

final sessionProvider =
    FutureProvider.family<CricketSession, String>(
  (ref, id) => ref.read(cricketRepositoryProvider).getSession(id),
);

// ─── Developer Options ────────────────────────────────────────────────────────
final showTrajectoryJsonProvider = StateProvider<bool>((ref) => false);

// ─── Selected Delivery (for cross-tab sharing in Session Detail) ──────────────
final selectedDeliveryIdProvider = StateProvider.family<String?, String>(
  (ref, sessionId) => null,
);
