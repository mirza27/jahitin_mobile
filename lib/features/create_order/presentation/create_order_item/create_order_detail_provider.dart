import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/job_item.dart';
import '../create_order/create_order_provider.dart';
import 'create_order_detail_state.dart';

class CreateOrderDetailNotifier extends Notifier<CreateOrderDetailState> {
  @override
  CreateOrderDetailState build() {
    final step1State = ref.watch(createOrderProvider);

    return CreateOrderDetailState(
      status: OrderDetailStatus.ready,
      customer: step1State.selectedCustomer,
      deadline: step1State.deadline,
      orderNotes: step1State.notes,
      jobs: const [],
      downPayment: 0,
    );
  }

  void addJob(JobItem job) {
    state = state.copyWith(jobs: [...state.jobs, job]);
  }

  void updateJob(JobItem updatedJob) {
    state = state.copyWith(
      jobs: state.jobs
          .map((j) => j.id == updatedJob.id ? updatedJob : j)
          .toList(),
    );
  }

  void removeJob(String jobId) {
    state = state.copyWith(
      jobs: state.jobs.where((j) => j.id != jobId).toList(),
    );
  }

  void setDownPayment(double amount) {
    state = state.copyWith(downPayment: amount);
  }

  Future<bool> submitOrder({bool isDraft = false}) async {
    state = state.copyWith(status: OrderDetailStatus.submitting);
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      state = state.copyWith(status: OrderDetailStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: OrderDetailStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void reset() {
    state = build();
  }
}

final createOrderDetailProvider =
    NotifierProvider<CreateOrderDetailNotifier, CreateOrderDetailState>(
      CreateOrderDetailNotifier.new,
    );
