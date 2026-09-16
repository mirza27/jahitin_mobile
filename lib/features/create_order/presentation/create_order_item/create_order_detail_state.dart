import '../../../../core/models/customer.dart';
import '../../../../core/models/job_item.dart';

enum OrderDetailStatus { initial, loading, ready, submitting, success, error }

class CreateOrderDetailState {
  final OrderDetailStatus status;
  final Customer? customer;
  final DateTime? deadline;
  final String orderNotes;
  final List<JobItem> jobs;
  final double downPayment;
  final String? errorMessage;

  const CreateOrderDetailState({
    this.status = OrderDetailStatus.ready,
    this.customer,
    this.deadline,
    this.orderNotes = '',
    this.jobs = const [],
    this.downPayment = 0,
    this.errorMessage,
  });

  double get totalCost =>
      jobs.fold(0.0, (sum, item) => sum + item.estimatedCost);

  double get remainingBalance =>
      (totalCost - downPayment).clamp(0.0, double.infinity);

  bool get canSubmit =>
      customer != null &&
      deadline != null &&
      jobs.isNotEmpty &&
      status != OrderDetailStatus.submitting;

  CreateOrderDetailState copyWith({
    OrderDetailStatus? status,
    Customer? customer,
    DateTime? deadline,
    String? orderNotes,
    List<JobItem>? jobs,
    double? downPayment,
    String? errorMessage,
  }) {
    return CreateOrderDetailState(
      status: status ?? this.status,
      customer: customer ?? this.customer,
      deadline: deadline ?? this.deadline,
      orderNotes: orderNotes ?? this.orderNotes,
      jobs: jobs ?? this.jobs,
      downPayment: downPayment ?? this.downPayment,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
