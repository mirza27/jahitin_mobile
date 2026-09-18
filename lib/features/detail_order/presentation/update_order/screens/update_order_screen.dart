import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations_ext.dart';
import '../../../model/detail_order.dart';
import '../update_order_provider.dart';
import '../update_order_state.dart';
import '../widgets/edit_job_bottom_sheet.dart';
import '../widgets/edit_job_card.dart';
import '../widgets/exit_confirmation_dialog.dart';

class UpdateOrderScreen extends ConsumerWidget {
  final DetailOrder detailOrder;

  const UpdateOrderScreen({super.key, required this.detailOrder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updateOrderProvider(detailOrder));
    final notifier = ref.read(updateOrderProvider(detailOrder).notifier);

    // Menangani error jika ada
    ref.listen(updateOrderProvider(detailOrder), (previous, next) {
      if (next.status == UpdateOrderStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final order = state.updatedDetailOrder;
    final title = (order?.name != null && order!.name!.isNotEmpty)
        ? order.name!
        : (order?.customerName ?? detailOrder.customerName);

    final deadlineText = _formatDeadline(order?.deadline ?? detailOrder.deadline);

    return PopScope(
      canPop: !state.anyChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldSave = await ExitConfirmationDialog.show(context);
        if (!context.mounted) return;

        if (shouldSave == true) {
          final success = await notifier.submitUpdate();
          if (success && context.mounted) {
            Navigator.of(context).pop(true);
          }
        } else if (shouldSave == false) {
          Navigator.of(context).pop(false);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryLight,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
            onPressed: () async {
              if (state.anyChanges) {
                final shouldSave = await ExitConfirmationDialog.show(context);
                if (!context.mounted) return;
                if (shouldSave == true) {
                  final success = await notifier.submitUpdate();
                  if (success && context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                } else if (shouldSave == false) {
                  Navigator.of(context).pop(false);
                }
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              if (deadlineText != null) ...[
                const SizedBox(height: 2),
                Text(
                  context.tr('deadline_prefix', params: {'deadline': deadlineText}),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol "+ Tambah Pekerjaan"
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final newItem = await EditJobBottomSheet.show(
                      context,
                      categories: state.categories,
                      serviceTypes: state.serviceTypes,
                      defaultClothesFor: detailOrder.customerName,
                    );
                    if (newItem != null) {
                      notifier.addJobItem(newItem);
                    }
                  },
                  icon: const Icon(Icons.add, size: 20, color: Colors.white),
                  label: Text(
                    context.tr('btn_add_job'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Daftar Card Pekerjaan
              if (order == null || order.orderItems.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      context.tr('empty_jobs_added'),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                ...order.orderItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: EditJobCard(
                      index: index,
                      item: item,
                      onEdit: () async {
                        final updatedItem = await EditJobBottomSheet.show(
                          context,
                          initialItem: item,
                          categories: state.categories,
                          serviceTypes: state.serviceTypes,
                          defaultClothesFor: detailOrder.customerName,
                        );
                        if (updatedItem != null) {
                          notifier.updateJobItem(index, updatedItem);
                        }
                      },
                      onDelete: () => notifier.removeJobItem(index),
                      onStatusChanged: (newStatus) =>
                          notifier.updateItemStatus(index, newStatus),
                    ),
                  );
                }),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(context, ref, state),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    UpdateOrderState state,
  ) {
    final notifier = ref.read(updateOrderProvider(detailOrder).notifier);
    final isUpdating = state.status == UpdateOrderStatus.updating;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isUpdating
                ? null
                : () async {
                    final success = await notifier.submitUpdate();
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.tr('order_updated_success')),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      Navigator.of(context).pop(true);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isUpdating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    context.tr('btn_save_order'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String? _formatDeadline(DateTime? deadline) {
    if (deadline == null) return null;
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(deadline);
  }
}
