import 'dart:convert';

import '../../domain/entities/auth_user.dart';

/// Serialisable [AuthUser] used by the data layer for session caching.
class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    super.phoneNumber,
    super.displayName,
    super.isGuest = false,
  });

  factory AuthUserModel.guest() =>
      const AuthUserModel(id: AuthUser.guestId, isGuest: true);

  /// Promotes a domain entity to a serialisable model.
  factory AuthUserModel.fromEntity(AuthUser user) => AuthUserModel(
        id: user.id,
        phoneNumber: user.phoneNumber,
        displayName: user.displayName,
        isGuest: user.isGuest,
      );

  factory AuthUserModel.fromMap(Map<String, dynamic> map) => AuthUserModel(
        id: map['id'] as String,
        phoneNumber: map['phoneNumber'] as String?,
        displayName: map['displayName'] as String?,
        isGuest: (map['isGuest'] as bool?) ?? false,
      );

  factory AuthUserModel.fromJson(String source) =>
      AuthUserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'phoneNumber': phoneNumber,
        'displayName': displayName,
        'isGuest': isGuest,
      };

  String toJson() => json.encode(toMap());
}
