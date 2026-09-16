import 'customer.dart';
import 'job_item.dart';

enum OrderStatus { belumMulai, diproses, selesai, dibatalkan }

class Order {
  final String id;
  final Customer customer;
  final DateTime deadline;
  final String? notes;
  final List<JobItem> jobs;
  final double downPayment;
  final OrderStatus status;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.customer,
    required this.deadline,
    this.notes,
    required this.jobs,
    this.downPayment = 0,
    this.status = OrderStatus.belumMulai,
    required this.createdAt,
  });

  double get totalCost =>
      jobs.fold(0.0, (sum, item) => sum + item.estimatedCost);

  double get remainingBalance =>
      (totalCost - downPayment).clamp(0.0, double.infinity);

  int get jobCount => jobs.length;
}
