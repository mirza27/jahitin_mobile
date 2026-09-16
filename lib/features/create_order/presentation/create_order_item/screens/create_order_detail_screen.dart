import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/models/job_item.dart';
import '../../create_order/create_order_provider.dart';
import '../../../widgets/add_job_sheet/add_job_bottom_sheet.dart';
import '../create_order_detail_provider.dart';
import '../create_order_detail_state.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/customer_summary_card.dart';
import '../widgets/job_item_card.dart';
import '../widgets/payment_breakdown_card.dart';

class CreateOrderDetailScreen extends ConsumerWidget {
  const CreateOrderDetailScreen({super.key});

  Future<void> _openAddJobSheet(
    BuildContext context,
    WidgetRef ref, {
    JobItem? existingJob,
  }) async {
    final state = ref.read(createOrderDetailProvider);
    final defaultRecipient = state.customer?.name ?? '';

    final result = await AddJobBottomSheet.show(
      context,
      existingJob: existingJob,
      defaultRecipientName: defaultRecipient,
    );

    if (result != null) {
      if (existingJob != null) {
        ref.read(createOrderDetailProvider.notifier).updateJob(result);
      } else {
        ref.read(createOrderDetailProvider.notifier).addJob(result);
      }
    }
  }

  void _handleSuccess(BuildContext context, WidgetRef ref, String message) {
    ref.read(createOrderProvider.notifier).reset();
    ref.read(createOrderDetailProvider.notifier).reset();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createOrderDetailProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Langkah 2 dari 2',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomerSummaryCard(
                      customer: state.customer,
                      deadline: state.deadline,
                      orderNotes: state.orderNotes,
                      onEditStep1: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daftar Pekerjaan (${state.jobs.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (state.jobs.isNotEmpty)
                          TextButton.icon(
                            onPressed: () => _openAddJobSheet(context, ref),
                            icon: const Icon(
                              Icons.add,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            label: const Text(
                              'Tambah',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (state.jobs.isEmpty)
                      _buildEmptyJobsPrompt(context, ref)
                    else ...[
                      ...state.jobs.map(
                        (job) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: JobItemCard(
                            job: job,
                            onEdit: () => _openAddJobSheet(
                              context,
                              ref,
                              existingJob: job,
                            ),
                            onDelete: () => ref
                                .read(createOrderDetailProvider.notifier)
                                .removeJob(job.id),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildAddJobOutlineButton(context, ref),
                    ],
                    const SizedBox(height: 24),
                    PaymentBreakdownCard(
                      totalCost: state.totalCost,
                      downPayment: state.downPayment,
                      remainingBalance: state.remainingBalance,
                      onDownPaymentChanged: (val) {
                        ref
                            .read(createOrderDetailProvider.notifier)
                            .setDownPayment(val);
                      },
                    ),
                  ],
                ),
              ),
            ),
            BottomActionBar(
              canSubmit: state.canSubmit,
              isSubmitting: state.status == OrderDetailStatus.submitting,
              onCreateOrder: () async {
                final success = await ref
                    .read(createOrderDetailProvider.notifier)
                    .submitOrder();
                if (success && context.mounted) {
                  _handleSuccess(context, ref, 'Pesanan berhasil dibuat!');
                }
              },
              onSaveDraft: () async {
                final success = await ref
                    .read(createOrderDetailProvider.notifier)
                    .submitOrder(isDraft: true);
                if (success && context.mounted) {
                  _handleSuccess(context, ref, 'Pesanan disimpan sebagai draf');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyJobsPrompt(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            radius: 28,
            child: const Icon(
              Icons.checkroom_outlined,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum Ada Pekerjaan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tambahkan pakaian yang akan dijahit atau dipermak pada pesanan ini',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => _openAddJobSheet(context, ref),
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'Tambah Pekerjaan Pertama',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddJobOutlineButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _openAddJobSheet(context, ref),
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Tambah Pekerjaan Lain',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
