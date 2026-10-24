// lib/data/mock/mock_cricket_repository.dart
// Mock implementation of CricketRepository using generated data.
// TODO(backend): Replace this class with a real API-backed implementation.

import '../models/session.dart';
import '../models/delivery.dart';
import '../models/enums.dart';
import '../models/user_profile.dart';
import '../repositories/cricket_repository.dart';
import 'mock_data_generator.dart';

class MockCricketRepository implements CricketRepository {
  MockCricketRepository() {
    _sessions = MockDataGenerator.generateSessions();
  }

  late final List<CricketSession> _sessions;
  UserProfile? _currentUser;

  @override
  Future<List<CricketSession>> getSessions() async {
    // TODO(backend): GET /api/sessions
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_sessions);
  }

  @override
  Future<CricketSession> getSession(String id) async {
    // TODO(backend): GET /api/sessions/{id}
    await Future.delayed(const Duration(milliseconds: 200));
    return _sessions.firstWhere((s) => s.id == id);
  }

  @override
  Future<List<Delivery>> getDeliveries(String sessionId) async {
    // TODO(backend): GET /api/sessions/{sessionId}/deliveries
    await Future.delayed(const Duration(milliseconds: 200));
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    return List.unmodifiable(session.deliveries);
  }

  @override
  Future<Delivery> getDelivery(String deliveryId) async {
    // TODO(backend): GET /api/deliveries/{deliveryId}
    await Future.delayed(const Duration(milliseconds: 100));
    for (final session in _sessions) {
      for (final delivery in session.deliveries) {
        if (delivery.id == deliveryId) return delivery;
      }
    }
    throw Exception('Delivery $deliveryId not found');
  }

  @override
  Future<String> startRecording() async {
    // TODO(backend): POST /api/recording/start → returns recording session ID
    await Future.delayed(const Duration(milliseconds: 100));
    return 'mock_recording_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<CricketSession> saveSession({
    required String recordingId,
    required String title,
    required String location,
  }) async {
    // TODO(backend): POST /api/recording/{recordingId}/process → triggers V4 pipeline
    await Future.delayed(const Duration(milliseconds: 600));
    final newSession = CricketSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      date: DateTime.now(),
      location: location,
      type: SessionType.practice,
      deliveries: MockDataGenerator.generateSessions().first.deliveries,
      isProcessed: true,
    );
    _sessions.insert(0, newSession);
    return newSession;
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<void> setCurrentUser(UserProfile profile) async {
    _currentUser = profile;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<List<MockTeammate>> getTeammates() async {
    // TODO(backend): GET /api/team/members
    await Future.delayed(const Duration(milliseconds: 200));
    return MockDataGenerator.generateTeammates();
  }
}
