import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

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

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // 0 = Aktif, 1 = Selesai
  int _selectedTab = 0;

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
      jobs: [
        'Jas - Jahit baru (untuk Pak Budi)',
      ],
    ),
  ];

  static const List<_Order> _doneOrders = [];

  @override
  Widget build(BuildContext context) {
    final orders = _selectedTab == 0 ? _activeOrders : _doneOrders;

    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNewOrderButton(),
                    const SizedBox(height: 20),
                    _buildTabs(),
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, Bu Siti 👋',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Anda memiliki 2 pesanan aktif',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {},
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

  Widget _buildTabs() {
    return Row(
      children: [
        _buildTabChip('Aktif (${_activeOrders.length})', 0),
        const SizedBox(width: 12),
        _buildTabChip('Selesai (${_doneOrders.length})', 1),
      ],
    );
  }

  Widget _buildTabChip(String label, int index) {
    final selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
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
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
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
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 12),
            const Text(
              'Belum ada pesanan selesai',
              style: TextStyle(
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
