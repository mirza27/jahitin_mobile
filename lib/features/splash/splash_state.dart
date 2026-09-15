enum SplashStatus { initial, loading, success, updateRequired, error }

enum AppState { unregistered, registered }

class SplashState {
  final SplashStatus status;
  final String? message;
  final AppState? appState;

  const SplashState({
    this.status = SplashStatus.initial,
    this.message,
    this.appState,
  });

  SplashState copyWith({
    SplashStatus? status,
    String? message,
    AppState? appState,
  }) {
    return SplashState(
      status: status ?? this.status,
      message: message ?? this.message,
      appState: appState ?? this.appState,
    );
  }
}
