import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/customer_contact.dart';
import 'create_order_state.dart';

class CreateOrderNotifier extends Notifier<CreateOrderState> {
  @override
  CreateOrderState build() {
    return const CreateOrderState(status: CreateOrderStatus.ready);
  }

  void updateOrderName(String name) {
    state = state.copyWith(orderName: name);
  }

  void selectCustomer(CustomerContact customer) {
    state = state.copyWith(selectedCustomer: customer);
  }

  void clearCustomer() {
    state = state.copyWith(clearCustomer: true);
  }

  void setDeadline(DateTime date) {
    state = state.copyWith(deadline: date, clearQuickDays: true);
  }

  void clearDeadline() {
    state = state.copyWith(clearDeadline: true, clearQuickDays: true);
  }

  void setQuickDeadline(int days) {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day + days);
    state = state.copyWith(deadline: target, selectedQuickDays: days);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void reset() {
    state = build();
  }
}

final createOrderProvider =
    NotifierProvider<CreateOrderNotifier, CreateOrderState>(
      CreateOrderNotifier.new,
    );
