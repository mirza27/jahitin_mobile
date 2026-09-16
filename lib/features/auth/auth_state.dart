import 'package:jahitin_mobile/core/models/user.dart';

enum AuthStatus { initial, loading, unauthenticated, authenticated, error }

enum AuthType { local, online }

class AuthState {
  final AuthStatus status;
  final String? message;
  final User? user;

  const AuthState({this.status = AuthStatus.initial, this.message, this.user});

  AuthState copyWith({
    AuthStatus? status,
    String? message,
    String? token,
    AuthType? authType,
    User? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      message: message ?? this.message,
      user: user ?? this.user,
    );
  }
}
