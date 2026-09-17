import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../create_order/presentation/create_order/screen/create_order_screen.dart';
import '../../../../detail_order/presentation/detail_order/screen/detail_order_screen.dart';
import '../../../widgets/config_sidebar.dart';
import '../../order_search/screens/order_search_screen.dart';
import '../home_provider.dart';
import '../home_state.dart';
import '../../../model/order_display.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final displayedOrders = homeState.displayedOrders;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.primaryLight,
          // Tombol "Pesanan Baru" dipindah ke bawah sebagai pinned footer
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: _buildNewOrderButton(context),
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context, ref, homeState),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () =>
                        ref.read(homeProvider.notifier).refreshOrders(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTabs(
                            ref,
                            homeState.selectedTab,
                            activeCount: homeState.activeOrders.length,
                            completedCount: homeState.completedOrders.length,
                          ),
                          const SizedBox(height: 12),
                          if (homeState.status == HomeStatus.loading &&
                              homeState.orderList.isEmpty)
                            _buildLoadingState()
                          else if (homeState.status == HomeStatus.error &&
                              homeState.orderList.isEmpty)
                            _buildErrorState(ref, homeState.message)
                          else if (displayedOrders.isEmpty)
                            _buildEmptyState(homeState.selectedTab)
                          else
                            ...displayedOrders.map(
                              (order) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildOrderCard(context, order),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const ConfigSidebar(),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    HomeState homeState,
  ) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              ref.read(homeProvider.notifier).toggleSidebar();
            },
            icon: const Icon(
              Icons.menu,
              color: AppColors.textPrimary,
              size: 24,
            ),
            tooltip: 'Menu',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  homeState.greetingText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  homeState.activeOrderSummary,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OrderSearchScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.search,
              color: AppColors.textPrimary,
              size: 24,
            ),
            tooltip: 'Cari Pesanan',
          ),
        ],
      ),
    );
  }

  Widget _buildNewOrderButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateOrderScreen()),
          );
        },
        icon: const Icon(Icons.add, size: 20, color: Colors.white),
        label: const Text(
          'Pesanan Baru',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(
    WidgetRef ref,
    HomeTab currentTab, {
    required int activeCount,
    required int completedCount,
  }) {
    return Row(
      children: [
        _buildTabChip(
          label: 'Aktif ($activeCount)',
          isSelected: currentTab == HomeTab.active,
          onTap: () => ref.read(homeProvider.notifier).setTab(HomeTab.active),
        ),
        const SizedBox(width: 8),
        _buildTabChip(
          label: 'Selesai ($completedCount)',
          isSelected: currentTab == HomeTab.completed,
          onTap: () =>
              ref.read(homeProvider.notifier).setTab(HomeTab.completed),
        ),
      ],
    );
  }

  Widget _buildTabChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderDisplay order) {
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
              '${order.itemCount} pekerjaan',
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
              ...items.map((item) {
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
              }),
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
    if (item.customServiceName != null && item.customServiceName!.isNotEmpty) {
      return item.customServiceName!;
    }
    return 'Pekerjaan jahitan';
  }

  String? _formatDeadline(DateTime? deadline) {
    if (deadline == null) return null;
    try {
      return DateFormat('EEE, d MMM', 'id_ID').format(deadline);
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
        label = 'Diproses';
        break;
      case OrderStatus.pending:
        bg = AppColors.statusNotStarted;
        fg = AppColors.statusNotStartedText;
        label = 'Belum mulai';
        break;
      case OrderStatus.completed:
        bg = AppColors.statusDone;
        fg = AppColors.statusDoneText;
        label = 'Selesai';
        break;
      case OrderStatus.pickedUp:
        bg = AppColors.statusDone;
        fg = AppColors.statusDoneText;
        label = 'Sudah Diambil';
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

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.only(top: 60),
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }

  Widget _buildErrorState(WidgetRef ref, String? message) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message ?? 'Gagal memuat daftar pesanan',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(homeProvider.notifier).fetchOrders(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(HomeTab tab) {
    final isTabActive = tab == HomeTab.active;
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 12),
            Text(
              isTabActive
                  ? 'Belum ada pesanan aktif'
                  : 'Belum ada pesanan selesai',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
