import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jahitin_mobile/features/create_order/model/create_order_item.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations_ext.dart';
import '../../../../home/presentation/home/home_provider.dart';
import '../../create_order/create_order_provider.dart';
import '../../handle_order_item/handle_order_item_bottom_sheet.dart';
import '../../select_customer/select_customer_provider.dart';
import '../create_order_detail_provider.dart';
import '../create_order_detail_state.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/customer_summary_card.dart';
import '../widgets/order_item_card.dart';
import '../widgets/payment_breakdown_card.dart';

class CreateOrderDetailScreen extends ConsumerStatefulWidget {
  const CreateOrderDetailScreen({super.key});

  @override
  ConsumerState<CreateOrderDetailScreen> createState() =>
      _CreateOrderDetailScreenState();
}

class _CreateOrderDetailScreenState
    extends ConsumerState<CreateOrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(createOrderDetailProvider.notifier).loadCategoriesAndServices();
    });
  }

  Future<void> _openAddOrderItemSheet(
    BuildContext context, {
    CreateOrderItem? existingOrderItem,
  }) async {
    final state = ref.read(createOrderDetailProvider);
    final defaultRecipient = state.customer?.displayName ?? '';
    final bool isFirstItem = existingOrderItem != null
        ? (state.orderItems.isNotEmpty &&
            state.orderItems.first.id == existingOrderItem.id)
        : state.orderItems.isEmpty;

    final result = await HandleOrderItemBottomSheet.show(
      context,
      existingOrderItem: existingOrderItem,
      defaultRecipientName: defaultRecipient,
      categories: state.clothesCategories,
      serviceTypes: state.serviceTypes,
      isFirstItem: isFirstItem,
    );

    if (result != null) {
      if (existingOrderItem != null) {
        ref.read(createOrderDetailProvider.notifier).updateOrderItem(result);
      } else {
        ref.read(createOrderDetailProvider.notifier).addOrderItem(result);
      }
    }
  }

  void _handleSuccess(String message) {
    ref.read(createOrderProvider.notifier).reset();
    ref.read(selectCustomerProvider.notifier).clearCustomer();
    ref.read(createOrderDetailProvider.notifier).reset();
    ref.read(homeProvider.notifier).refreshOrders();

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
  Widget build(BuildContext context) {
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
        title: Text(
          context.tr('order_detail'),
          style: const TextStyle(
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
            child: Text(
              context.tr('step_2_of_2'),
              style: const TextStyle(
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
                      orderName: state.orderName,
                      customer: state.customer,
                      deadline: state.deadline,
                      onEditStep1: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      context.tr(
                        'job_list_with_count',
                        params: {'count': '${state.orderItems.length}'},
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (state.orderItems.isEmpty)
                      _buildEmptyOrderItemsPrompt(context)
                    else ...[
                      ...state.orderItems.map(
                        (orderItem) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OrderItemCard(
                            item: orderItem,
                            onEdit: () => _openAddOrderItemSheet(
                              context,
                              existingOrderItem: orderItem,
                            ),
                            onDelete: () => ref
                                .read(createOrderDetailProvider.notifier)
                                .removeOrderItem(orderItem.id),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildAddOrderItemOutlineButton(context),
                    ],
                    const SizedBox(height: 24),
                    PaymentBreakdownCard(
                      totalCost: state.totalCost,
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
                  _handleSuccess(context.tr('order_created_success'));
                } else if (!success && context.mounted) {
                  final error = ref
                      .read(createOrderDetailProvider)
                      .errorMessage;
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrderItemsPrompt(BuildContext context) {
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
          Text(
            context.tr('empty_jobs_title'),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('empty_jobs_subtitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
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
            onPressed: () => _openAddOrderItemSheet(context),
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              context.tr('btn_add_first_job'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOrderItemOutlineButton(BuildContext context) {
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
        onPressed: () => _openAddOrderItemSheet(context),
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          context.tr('btn_add_another_job'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
