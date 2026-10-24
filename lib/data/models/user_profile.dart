// lib/data/models/user_profile.dart

import 'enums.dart';

class UserProfile {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final String avatarInitials;
  final bool isPro;
  final double storageUsedGb;
  final double storageTotalGb;

  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.avatarInitials,
    this.isPro = false,
    this.storageUsedGb = 1.2,
    this.storageTotalGb = 5.0,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? phone,
    UserRole? role,
    String? avatarInitials,
    bool? isPro,
    double? storageUsedGb,
    double? storageTotalGb,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      isPro: isPro ?? this.isPro,
      storageUsedGb: storageUsedGb ?? this.storageUsedGb,
      storageTotalGb: storageTotalGb ?? this.storageTotalGb,
    );
  }
}

class MockTeammate {
  final String id;
  final String name;
  final String initials;
  final UserRole role;

  const MockTeammate({
    required this.id,
    required this.name,
    required this.initials,
    required this.role,
  });
}
