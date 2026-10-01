import '../../model/customer_contact.dart';

enum SelectCustomerStatus { initial, loading, ready, error }

enum ContactPermission { initial, granted, denied, permanentlyDenied }

class SelectCustomerState {
  final SelectCustomerStatus status;
  final ContactPermission contactPermission;
  final List<CustomerContact> customers;
  final CustomerContact? selectedCustomer;
  final String? errorMessage;

  const SelectCustomerState({
    this.status = SelectCustomerStatus.initial,
    this.customers = const [],
    this.selectedCustomer,
    this.errorMessage,
    this.contactPermission = ContactPermission.initial,
  });

  SelectCustomerState copyWith({
    SelectCustomerStatus? status,
    List<CustomerContact>? customers,
    CustomerContact? selectedCustomer,
    ContactPermission? contactPermission,
    bool clearSelectedCustomer = false,
    String? errorMessage,
  }) {
    return SelectCustomerState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      selectedCustomer: clearSelectedCustomer
          ? null
          : (selectedCustomer ?? this.selectedCustomer),
      contactPermission: contactPermission ?? this.contactPermission,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
