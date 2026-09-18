import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations_ext.dart';
import '../../../model/detail_order.dart';
import '../detail_order_provider.dart';
import '../detail_order_state.dart';
import '../../update_order/screens/update_order_screen.dart';

class DetailOrderScreen extends ConsumerWidget {
  const DetailOrderScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(detailOrderProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      appBar: AppBar(
        title: _buildAppBarTitle(context, detailState),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          if (detailState.status == DetailOrderStatus.loaded &&
              detailState.detailOrder != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: _buildStatusChip(context, detailState.detailOrder!.status),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref
            .read(detailOrderProvider(orderId).notifier)
            .fetchDetailOrder(orderId),
        child: _buildBody(context, ref, detailState),
      ),
      bottomNavigationBar:
          (detailState.status == DetailOrderStatus.loaded &&
                  detailState.detailOrder != null)
              ? _buildBottomBar(context, ref, detailState.detailOrder!)
              : null,
    );
  }

  Widget _buildAppBarTitle(BuildContext context, DetailOrderState state) {
    if (state.status == DetailOrderStatus.loaded &&
        state.detailOrder != null) {
      final order = state.detailOrder!;
      final title = (order.name != null && order.name!.isNotEmpty)
          ? order.name!
          : order.customerName;
      return Column(
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
          const SizedBox(height: 2),
          Text(
            context.tr(
              'job_count',
              params: {'count': '${order.items.length}'},
            ),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    return Text(
      context.tr('order_detail'),
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    DetailOrderState state,
  ) {
    switch (state.status) {
      case DetailOrderStatus.initial:
      case DetailOrderStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      case DetailOrderStatus.error:
        return _buildErrorState(context, ref, state.message);
      case DetailOrderStatus.loaded:
        if (state.detailOrder == null) {
          return _buildEmptyState(context);
        }
        return _buildContent(context, state.detailOrder!);
    }
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String? message) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 400,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message ?? context.tr('error_load_detail'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(detailOrderProvider(orderId).notifier)
                    .fetchDetailOrder(orderId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                context.tr('retry'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 400,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 56, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              context.tr('detail_not_found'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DetailOrder order) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeaderCard(context, order),
          const SizedBox(height: 16),
          _buildJobListSection(context, order.items),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOrderHeaderCard(BuildContext context, DetailOrder order) {
    final deadlineText = _formatDeadline(order.deadline);

    final completedCount = order.items.where((item) {
      final s = (item.status ?? '').trim().toLowerCase().replaceAll('_', '');
      return s == 'completed' || s == 'selesai' || s == 'done';
    }).length;

    final formattedTotal = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(order.totalPrice);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Name
          Text(
            context.tr('customer_name_label'),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            order.customerName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          // Phone
          if (order.customerPhone != null &&
              order.customerPhone!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              context.tr('phone_label'),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              order.customerPhone!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],

          // Deadline
          if (deadlineText != null) ...[
            const SizedBox(height: 12),
            Text(
              context.tr('deadline'),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              deadlineText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],

          // Divider
          const SizedBox(height: 14),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 14),

          // Total Pekerjaan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('total_jobs_label'),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${order.items.length}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Selesai
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('completed_jobs_label'),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$completedCount / ${order.items.length}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          // Divider
          const SizedBox(height: 14),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 14),

          // Total Biaya
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('total_cost'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                formattedTotal,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobListSection(BuildContext context, List<DetailOrderItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('job_list'),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              context.tr('no_job_items'),
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          )
        else
          ...items.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildJobItemCard(context, entry.value, entry.key),
            ),
          ),
      ],
    );
  }

  Widget _buildJobItemCard(BuildContext context, DetailOrderItem item, int index) {
    final clothesTitle =
        (item.clothesFor != null && item.clothesFor!.isNotEmpty)
        ? item.clothesFor!
        : (item.clothesCategoryName ?? context.tr('default_garment_fallback'));

    final serviceType =
        (item.customServiceName != null && item.customServiceName!.isNotEmpty)
        ? item.customServiceName!
        : (item.serviceTypeName ?? '-');

    final priceFormatted = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(item.price);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Index number + Status chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${index + 1}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              if (item.status != null && item.status!.isNotEmpty)
                _buildStatusChip(context, item.status!),
            ],
          ),
          const SizedBox(height: 6),

          // Garment title
          Text(
            item.clothesCategoryName ?? clothesTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),

          // Service type
          Text(
            serviceType,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),

          // Divider
          const SizedBox(height: 10),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 10),

          // Untuk:
          if (item.clothesFor != null && item.clothesFor!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Text(
                    '${context.tr('for_recipient_prefix', params: {'name': ''}).replaceAll('{name}', '')} ',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.clothesFor!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Biaya:
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('price_label'),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                priceFormatted,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          // Notes
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.note_alt_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.notes!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    DetailOrder detailOrder,
  ) {
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
          child: OutlinedButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) =>
                      UpdateOrderScreen(detailOrder: detailOrder),
                ),
              );

              if (result == true) {
                ref
                    .read(detailOrderProvider(orderId).notifier)
                    .fetchDetailOrder(orderId);
              }
            },
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.textPrimary,
            ),
            label: Text(
              context.tr('btn_edit_order'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final normalized = status.trim().toLowerCase().replaceAll('_', '');
    Color bgColor;
    Color textColor;
    String label;

    switch (normalized) {
      case 'inprogress':
        bgColor = AppColors.statusProcessed;
        textColor = AppColors.statusProcessedText;
        label = context.tr('status_processed');
        break;
      case 'completed':
      case 'selesai':
        bgColor = AppColors.statusDone;
        textColor = AppColors.statusDoneText;
        label = context.tr('status_done');
        break;
      case 'taken':
      case 'sudahdiambil':
        bgColor = AppColors.statusDone;
        textColor = AppColors.statusDoneText;
        label = context.tr('status_picked_up');
        break;
      case 'pending':
      default:
        bgColor = AppColors.statusNotStarted;
        textColor = AppColors.statusNotStartedText;
        label = context.tr('status_not_started');
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String? _formatDeadline(DateTime? deadline) {
    if (deadline == null) return null;
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(deadline);
  }
}
