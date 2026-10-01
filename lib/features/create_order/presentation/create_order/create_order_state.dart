import '../../model/customer_contact.dart';

enum CreateOrderStatus { initial, loading, ready, error }

class CreateOrderState {
  final CreateOrderStatus status;
  final CustomerContact? selectedCustomer;
  final DateTime? deadline;
  final int? selectedQuickDays;
  final String notes;
  final String? errorMessage;

  const CreateOrderState({
    this.status = CreateOrderStatus.initial,
    this.selectedCustomer,
    this.deadline,
    this.selectedQuickDays,
    this.notes = '',
    this.errorMessage,
  });

  bool get isValid => selectedCustomer != null && deadline != null;

  CreateOrderState copyWith({
    CreateOrderStatus? status,
    CustomerContact? selectedCustomer,
    bool clearCustomer = false,
    DateTime? deadline,
    bool clearDeadline = false,
    int? selectedQuickDays,
    bool clearQuickDays = false,
    String? notes,
    String? errorMessage,
  }) {
    return CreateOrderState(
      status: status ?? this.status,
      selectedCustomer: clearCustomer
          ? null
          : (selectedCustomer ?? this.selectedCustomer),
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      selectedQuickDays: clearQuickDays
          ? null
          : (selectedQuickDays ?? this.selectedQuickDays),
      notes: notes ?? this.notes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
