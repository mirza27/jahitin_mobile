import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../model/update_detail_order.dart';

class EditJobCard extends StatelessWidget {
  final int index;
  final UpdateOrderItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<String> onStatusChanged;

  const EditJobCard({
    super.key,
    required this.index,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
  });

  static const List<Map<String, String>> _statusOptions = [
    {'key': 'pending', 'label': 'Belum mulai'},
    {'key': 'inprogress', 'label': 'Diproses'},
    {'key': 'completed', 'label': 'Selesai'},
    {'key': 'taken', 'label': 'Sudah diambil'},
  ];

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final garmentTitle = (item.categoryName != null && item.categoryName!.isNotEmpty)
        ? item.categoryName!
        : 'Pakaian';

    final serviceTitle = (item.customServiceName != null && item.customServiceName!.isNotEmpty)
        ? item.customServiceName!
        : (item.serviceName != null && item.serviceName!.isNotEmpty
            ? item.serviceName!
            : '-');

    final currentStatus = _normalizeStatus(item.status);

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
          // Row Header: #Index & Delete Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${index + 1}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          // Tappable area to edit
          InkWell(
            onTap: onEdit,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Garment Type
                Text(
                  garmentTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                // Service Name
                Text(
                  serviceTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),

                // Untuk:
                if (item.clothesFor != null && item.clothesFor!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Untuk: ${item.clothesFor}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                // Divider
                const Divider(color: AppColors.divider, height: 16),

                // Biaya
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Biaya:',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      currencyFormat.format(item.price),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),

                // Catatan jika ada
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Catatan: ${item.notes}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Horizontal Status Options Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusOptions.map((opt) {
                final isSelected = currentStatus == opt['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildStatusSelectChip(
                    label: opt['label']!,
                    isSelected: isSelected,
                    onTap: () => onStatusChanged(opt['key']!),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSelectChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  String _normalizeStatus(String? status) {
    if (status == null) return 'pending';
    final s = status.trim().toLowerCase().replaceAll('_', '');
    if (s == 'inprogress' || s == 'diproses') return 'inprogress';
    if (s == 'completed' || s == 'selesai' || s == 'done') return 'completed';
    if (s == 'taken' || s == 'sudahdiambil') return 'taken';
    return 'pending';
  }
}
