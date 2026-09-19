import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations_ext.dart';
import '../../../../detail_order/presentation/detail_order/screen/detail_order_screen.dart';
import '../../../model/order_display.dart';
import '../order_search_provider.dart';
import '../order_search_state.dart';

class OrderSearchScreen extends ConsumerStatefulWidget {
  const OrderSearchScreen({super.key});

  @override
  ConsumerState<OrderSearchScreen> createState() => _OrderSearchScreenState();
}

class _OrderSearchScreenState extends ConsumerState<OrderSearchScreen> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        ref.read(orderSearchProvider.notifier).fetchOrders(query);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(orderSearchProvider.notifier).clearSearch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(orderSearchProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildSearchHeader(),
            Expanded(
              child: _buildBody(searchState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: context.tr('search_hint'),
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.textSecondary,
                                size: 18,
                              ),
                              onPressed: _clearSearch,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 4, right: 12),
                              child: Icon(
                                Icons.search,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                            ),
                          ],
                        )
                      : const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                onChanged: (val) {
                  setState(() {});
                  _onSearchChanged(val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(OrderSearchState searchState) {
    switch (searchState.status) {
      case OrderSearchStatus.initial:
        return _buildInitialState();
      case OrderSearchStatus.loading:
        return _buildLoadingState();
      case OrderSearchStatus.error:
        return _buildErrorState(searchState.message);
      case OrderSearchStatus.loaded:
        if (searchState.orderList.isEmpty) {
          return _buildEmptyState(searchState.searchQuery);
        }
        return _buildOrderList(searchState.orderList);
    }
  }

  Widget _buildInitialState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_rounded,
              size: 56,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('search_initial_title'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('search_initial_desc'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildErrorState(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message ?? context.tr('search_error'),
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
                    .read(orderSearchProvider.notifier)
                    .fetchOrders(_searchController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: Text(context.tr('retry')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String? query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 56,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('search_empty_title'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              query != null && query.isNotEmpty
                  ? context.tr('search_empty_query_desc', params: {'query': query})
                  : context.tr('search_empty_desc'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderDisplay> orders) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOrderCard(order),
        );
      },
    );
  }

  Widget _buildOrderCard(OrderDisplay order) {
    final deadlineText = _formatDeadline(order.deadline);
    final items = order.orderDisplayItems ?? [];

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailOrderScreen(orderId: order.orderId),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    order.customerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _buildStatusChip(order.orderStatus),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              context.tr('job_count', params: {'count': '${order.itemCount}'}),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            if (deadlineText != null) ...[
              const SizedBox(height: 10),
              _buildDateChip(deadlineText, order.orderStatus),
            ],
            if (items.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...items.map(
                (item) {
                  final itemLabel = _getItemDescription(item);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $itemLabel',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  );
                },
              ),
            ] else if (order.name != null && order.name!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${order.name}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getItemDescription(OrderItemDisplay item) {
    if (item.clothesFor != null && item.clothesFor!.isNotEmpty) {
      if (item.customServiceName != null &&
          item.customServiceName!.isNotEmpty) {
        return '${item.clothesFor} - ${item.customServiceName}';
      }
      return item.clothesFor!;
    }
    if (item.customServiceName != null &&
        item.customServiceName!.isNotEmpty) {
      return item.customServiceName!;
    }
    return context.tr('default_job_item');
  }

  String? _formatDeadline(DateTime? deadline) {
    if (deadline == null) return null;
    final locale = Localizations.localeOf(context).toString();
    try {
      return DateFormat('EEE, d MMM', locale).format(deadline);
    } catch (_) {
      return DateFormat('d MMM yyyy').format(deadline);
    }
  }

  Widget _buildStatusChip(OrderStatus status) {
    late final Color bg;
    late final Color fg;
    late final String label;

    switch (status) {
      case OrderStatus.inProgress:
        bg = AppColors.statusProcessed;
        fg = AppColors.statusProcessedText;
        label = context.tr('status_processed');
        break;
      case OrderStatus.pending:
        bg = AppColors.statusNotStarted;
        fg = AppColors.statusNotStartedText;
        label = context.tr('status_not_started');
        break;
      case OrderStatus.completed:
        bg = AppColors.statusDone;
        fg = AppColors.statusDoneText;
        label = context.tr('status_done');
        break;
      case OrderStatus.pickedUp:
        bg = AppColors.statusDone;
        fg = AppColors.statusDoneText;
        label = context.tr('status_picked_up');
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _buildDateChip(String dateLabel, OrderStatus status) {
    final highlighted = status == OrderStatus.inProgress;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primaryLight : AppColors.divider,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            dateLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: highlighted
                  ? AppColors.statusProcessedText
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
