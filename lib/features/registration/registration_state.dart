enum RegistrationStatus { initial, loading, success, error }

class RegistrationState {
  final RegistrationStatus status;
  final String? message;

  const RegistrationState({
    this.status = RegistrationStatus.initial,
    this.message,
  });

  RegistrationState copyWith({RegistrationStatus? status, String? message}) {
    return RegistrationState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
