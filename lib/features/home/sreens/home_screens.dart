import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../create_order/presentation/create_order/screen/create_order_screen.dart';
import '../home_provider.dart';
import '../home_state.dart';

/// Dummy order status shown on each card.
enum _OrderStatus { diproses, belumMulai, selesai }

/// Dummy model for a customer's order group.
class _Order {
  final String customer;
  final int jobCount;
  final String dateLabel;
  final _OrderStatus status;
  final List<String> jobs;

  const _Order({
    required this.customer,
    required this.jobCount,
    required this.dateLabel,
    required this.status,
    required this.jobs,
  });
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<_Order> _activeOrders = [
    _Order(
      customer: 'Bu Siti',
      jobCount: 2,
      dateLabel: 'Sab, 4 Jul',
      status: _OrderStatus.diproses,
      jobs: [
        'Gamis - Kecilkan (untuk Bu Siti)',
        'Rok - Ganti resleting (untuk Alya)',
      ],
    ),
    _Order(
      customer: 'Ibu Dewi',
      jobCount: 1,
      dateLabel: 'Rab, 8 Jul',
      status: _OrderStatus.belumMulai,
      jobs: ['Jas - Jahit baru (untuk Pak Budi)'],
    ),
  ];

  static const List<_Order> _doneOrders = [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final orders = homeState.selectedTab == HomeTab.active
        ? _activeOrders
        : _doneOrders;

    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(homeState),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNewOrderButton(context),
                    const SizedBox(height: 20),
                    _buildTabs(ref, homeState.selectedTab),
                    const SizedBox(height: 20),
                    if (orders.isEmpty)
                      _buildEmptyState()
                    else
                      ...orders.map(
                        (o) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildOrderCard(o),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(HomeState homeState) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            homeState.greetingText,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            homeState.activeOrderSummary,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewOrderButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateOrderScreen()),
          );
        },
        icon: const Icon(Icons.add, size: 22, color: Colors.white),
        label: const Text(
          'Pesanan Baru',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(WidgetRef ref, HomeTab currentTab) {
    return Row(
      children: [
        _buildTabChip(
          label: 'Aktif (${_activeOrders.length})',
          isSelected: currentTab == HomeTab.active,
          onTap: () => ref.read(homeProvider.notifier).setTab(HomeTab.active),
        ),
        const SizedBox(width: 12),
        _buildTabChip(
          label: 'Selesai (${_doneOrders.length})',
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
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(_Order order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  order.customer,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _buildStatusChip(order.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${order.jobCount} pekerjaan',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          _buildDateChip(order.dateLabel, order.status),
          const SizedBox(height: 14),
          ...order.jobs.map(
            (job) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• $job',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(_OrderStatus status) {
    late final Color bg;
    late final Color fg;
    late final String label;

    switch (status) {
      case _OrderStatus.diproses:
        bg = AppColors.statusProcessed;
        fg = AppColors.statusProcessedText;
        label = 'Diproses';
        break;
      case _OrderStatus.belumMulai:
        bg = AppColors.statusNotStarted;
        fg = AppColors.statusNotStartedText;
        label = 'Belum mulai';
        break;
      case _OrderStatus.selesai:
        bg = AppColors.statusDone;
        fg = AppColors.statusDoneText;
        label = 'Selesai';
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

  Widget _buildDateChip(String dateLabel, _OrderStatus status) {
    final highlighted = status == _OrderStatus.diproses;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primaryLight : AppColors.divider,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📅', style: TextStyle(fontSize: 14)),
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: AppColors.textHint),
            const SizedBox(height: 12),
            const Text(
              'Belum ada pesanan selesai',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
