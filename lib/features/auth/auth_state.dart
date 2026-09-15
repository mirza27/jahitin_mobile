enum AuthStatus { initial, loading, unauthenticated, authenticated, error }

enum AuthType { local, online }

class AuthState {
  final AuthStatus status;
  final String? message;
  final String? token;
  final AuthType? authType;

  const AuthState({
    this.status = AuthStatus.initial,
    this.message,
    this.token,
    this.authType,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? message,
    String? token,
    AuthType? authType,
  }) {
    return AuthState(
      status: status ?? this.status,
      message: message ?? this.message,
      token: token ?? this.token,
      authType: authType ?? this.authType,
    );
  }
}
