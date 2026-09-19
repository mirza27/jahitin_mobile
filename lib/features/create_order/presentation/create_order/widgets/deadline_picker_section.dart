import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations_ext.dart';
import '../create_order_provider.dart';
import 'quick_date_chip.dart';

class DeadlinePickerSection extends ConsumerWidget {
  const DeadlinePickerSection({super.key});

  static const _quickOptions = [
    (key: 'quick_3_days', days: 3),
    (key: 'quick_1_week', days: 7),
    (key: 'quick_2_weeks', days: 14),
  ];

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final state = ref.read(createOrderProvider);
    final now = DateTime.now();
    final initialDate = state.deadline != null && state.deadline!.isAfter(now)
        ? state.deadline!
        : now.add(const Duration(days: 3));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(createOrderProvider.notifier).setDeadline(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createOrderProvider);
    final deadline = state.deadline;
    final selectedDays = state.selectedQuickDays;

    String deadlineText;
    if (deadline != null) {
      deadlineText = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(deadline);
    } else {
      deadlineText = context.tr('select_deadline_placeholder');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('target_deadline_title'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _quickOptions.map((opt) {
            final isSelected = selectedDays == opt.days;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: QuickDateChip(
                label: context.tr(opt.key),
                isSelected: isSelected,
                onTap: () => ref
                    .read(createOrderProvider.notifier)
                    .setQuickDeadline(opt.days),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _pickDate(context, ref),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: deadline != null
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.border,
                width: deadline != null ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: deadline != null
                      ? AppColors.primary
                      : AppColors.textHint,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    deadlineText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: deadline != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: deadline != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: deadline != null
                      ? AppColors.primary
                      : AppColors.textHint,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
