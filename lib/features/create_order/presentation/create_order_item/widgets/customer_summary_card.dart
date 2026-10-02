import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations_ext.dart';
import '../../../model/customer_contact.dart';

class CustomerSummaryCard extends StatelessWidget {
  final String orderName;
  final CustomerContact? customer;
  final DateTime? deadline;
  final String orderNotes;
  final VoidCallback? onEditStep1;

  const CustomerSummaryCard({
    super.key,
    required this.orderName,
    required this.customer,
    required this.deadline,
    required this.orderNotes,
    this.onEditStep1,
  });

  @override
  Widget build(BuildContext context) {
    final deadlineFormatted = deadline != null
        ? DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(deadline!)
        : context.tr('target_deadline_none');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    radius: 18,
                    child: Text(
                      customer != null && customer!.displayName.isNotEmpty
                          ? customer!.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer?.displayName ?? context.tr('no_customer_assigned'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (customer?.phoneNumber != null &&
                          customer!.phoneNumber.isNotEmpty)
                        Text(
                          customer!.phoneNumber,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (onEditStep1 != null)
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  onPressed: onEditStep1,
                  tooltip: context.tr('tooltip_edit_customer_target'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          if (orderName.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('order_name_label'),
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                Expanded(
                  child: Text(
                    orderName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                context.tr('target_deadline_label'),
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              Expanded(
                child: Text(
                  deadlineFormatted,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (orderNotes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.note_alt_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    orderNotes,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
