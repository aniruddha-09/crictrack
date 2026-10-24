// lib/data/repositories/cricket_repository.dart
// Abstract repository interface. Swap MockCricketRepository for a real
// backend implementation with no UI changes.

import '../models/session.dart';
import '../models/delivery.dart';
import '../models/user_profile.dart';

abstract class CricketRepository {
  // ─── Sessions ─────────────────────────────────────────────────────────────
  Future<List<CricketSession>> getSessions();
  Future<CricketSession> getSession(String id);

  // ─── Deliveries ───────────────────────────────────────────────────────────
  Future<List<Delivery>> getDeliveries(String sessionId);
  Future<Delivery> getDelivery(String deliveryId);

  // ─── Recording ────────────────────────────────────────────────────────────
  // TODO(backend): Call backend API to start a recording session.
  Future<String> startRecording();

  // TODO(backend): Call backend API to save and process the recorded session.
  Future<CricketSession> saveSession({
    required String recordingId,
    required String title,
    required String location,
  });

  // ─── User ─────────────────────────────────────────────────────────────────
  Future<UserProfile?> getCurrentUser();
  Future<void> setCurrentUser(UserProfile profile);
  Future<void> logout();

  // ─── Teammates ────────────────────────────────────────────────────────────
  Future<List<MockTeammate>> getTeammates();
}
