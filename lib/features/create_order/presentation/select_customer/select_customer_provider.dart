import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/customer.dart';
import 'select_customer_state.dart';

class SelectCustomerNotifier extends Notifier<SelectCustomerState> {
  @override
  SelectCustomerState build() {
    return const SelectCustomerState(
      status: SelectCustomerStatus.ready,
      customers: [
        Customer(
          id: '1',
          name: 'Bu Siti',
          phone: '081234567890',
          address: 'Jl. Melati No. 12',
        ),
        Customer(
          id: '2',
          name: 'Ibu Dewi',
          phone: '081298765432',
          address: 'Jl. Mawar No. 45',
        ),
        Customer(
          id: '3',
          name: 'Pak Budi',
          phone: '081311223344',
          address: 'Jl. Anggrek No. 8',
        ),
      ],
    );
  }

  void selectCustomer(Customer customer) {
    state = state.copyWith(selectedCustomer: customer);
  }

  void clearCustomer() {
    state = state.copyWith(clearSelectedCustomer: true);
  }

  Customer createCustomer({
    required String name,
    required String phone,
    String? address,
  }) {
    final customer = Customer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
      address: address,
    );
    state = state.copyWith(
      selectedCustomer: customer,
      customers: [...state.customers, customer],
    );
    return customer;
  }

  void reset() {
    state = build();
  }
}

final selectCustomerProvider =
    NotifierProvider<SelectCustomerNotifier, SelectCustomerState>(
      SelectCustomerNotifier.new,
    );
