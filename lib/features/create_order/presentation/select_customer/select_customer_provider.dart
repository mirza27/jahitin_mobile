import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/customer_contact.dart';
import 'select_customer_state.dart';

class SelectCustomerNotifier extends Notifier<SelectCustomerState> {
  @override
  SelectCustomerState build() {
    return const SelectCustomerState(
      status: SelectCustomerStatus.initial,
      contactPermission: ContactPermission.initial,
    );
  }

  Future<void> checkAndLoadContacts() async {
    state = state.copyWith(status: SelectCustomerStatus.loading);

    try {
      final status =
          await FlutterContacts.permissions.request(PermissionType.read);

      if (status == PermissionStatus.granted ||
          status == PermissionStatus.limited) {
        state = state.copyWith(contactPermission: ContactPermission.granted);
        await _loadContactsFromDevice();
      } else if (status == PermissionStatus.permanentlyDenied) {
        state = state.copyWith(
          contactPermission: ContactPermission.permanentlyDenied,
          status: SelectCustomerStatus.error,
          errorMessage: 'Izin kontak ditolak secara permanen.',
        );
      } else {
        state = state.copyWith(
          contactPermission: ContactPermission.denied,
          status: SelectCustomerStatus.error,
          errorMessage: 'Izin kontak ditolak.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        contactPermission: ContactPermission.denied,
        status: SelectCustomerStatus.error,
        errorMessage: 'Gagal meminta izin kontak: $e',
      );
    }
  }

  Future<void> _loadContactsFromDevice() async {
    try {
      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.name, ContactProperty.phone},
      );

      final customerContacts = contacts
          .where((c) => c.phones.isNotEmpty)
          .map(
            (c) => CustomerContact(
              displayName: (c.displayName ?? '').isNotEmpty
                  ? c.displayName!
                  : 'Tanpa Nama',
              phoneNumber: c.phones.first.number,
              contactId: c.id ?? '',
            ),
          )
          .toList();

      state = state.copyWith(
        status: SelectCustomerStatus.ready,
        customers: customerContacts,
      );
    } catch (e) {
      state = state.copyWith(
        status: SelectCustomerStatus.error,
        errorMessage: 'Gagal memuat kontak: $e',
      );
    }
  }

  void selectCustomer(CustomerContact customer) {
    state = state.copyWith(selectedCustomer: customer);
  }

  void clearCustomer() {
    state = state.copyWith(clearSelectedCustomer: true);
  }

  CustomerContact createCustomer({
    required String name,
    required String phone,
    String? address,
  }) {
    final customer = CustomerContact(
      displayName: name,
      phoneNumber: phone,
      contactId: DateTime.now().millisecondsSinceEpoch.toString(),
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
