import '../../model/customer_contact.dart';

enum CreateOrderStatus { initial, loading, ready, error }

class CreateOrderState {
  final CreateOrderStatus status;
  final String orderName;
  final CustomerContact? selectedCustomer;
  final DateTime? deadline;
  final int? selectedQuickDays;
  final String? errorMessage;

  const CreateOrderState({
    this.status = CreateOrderStatus.initial,
    this.orderName = '',
    this.selectedCustomer,
    this.deadline,
    this.selectedQuickDays,
    this.errorMessage,
  });

  bool get isValid =>
      orderName.trim().isNotEmpty && selectedCustomer != null;

  /// Deadline bersifat opsional; gunakan string kosong jika null
  String get deadlineOrEmpty =>
      deadline != null ? deadline!.toIso8601String() : '';

  CreateOrderState copyWith({
    CreateOrderStatus? status,
    String? orderName,
    CustomerContact? selectedCustomer,
    bool clearCustomer = false,
    DateTime? deadline,
    bool clearDeadline = false,
    int? selectedQuickDays,
    bool clearQuickDays = false,
    String? errorMessage,
  }) {
    return CreateOrderState(
      status: status ?? this.status,
      orderName: orderName ?? this.orderName,
      selectedCustomer: clearCustomer
          ? null
          : (selectedCustomer ?? this.selectedCustomer),
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      selectedQuickDays: clearQuickDays
          ? null
          : (selectedQuickDays ?? this.selectedQuickDays),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
