import '../../../../core/models/customer.dart';

enum SelectCustomerStatus { initial, ready, error }

class SelectCustomerState {
  final SelectCustomerStatus status;
  final List<Customer> customers;
  final Customer? selectedCustomer;
  final String? errorMessage;

  const SelectCustomerState({
    this.status = SelectCustomerStatus.initial,
    this.customers = const [],
    this.selectedCustomer,
    this.errorMessage,
  });

  SelectCustomerState copyWith({
    SelectCustomerStatus? status,
    List<Customer>? customers,
    Customer? selectedCustomer,
    bool clearSelectedCustomer = false,
    String? errorMessage,
  }) {
    return SelectCustomerState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      selectedCustomer: clearSelectedCustomer
          ? null
          : (selectedCustomer ?? this.selectedCustomer),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
