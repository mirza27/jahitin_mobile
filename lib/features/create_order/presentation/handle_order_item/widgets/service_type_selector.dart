import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations_ext.dart';
import '../handle_order_item_provider.dart';

class ServiceTypeSelector extends ConsumerStatefulWidget {
  const ServiceTypeSelector({super.key});

  @override
  ConsumerState<ServiceTypeSelector> createState() =>
      _ServiceTypeSelectorState();
}

class _ServiceTypeSelectorState extends ConsumerState<ServiceTypeSelector> {
  late final TextEditingController _customServiceController;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(handleOrderItemProvider).customServiceName;
    _customServiceController = TextEditingController(text: initial ?? '');
  }

  @override
  void dispose() {
    _customServiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(handleOrderItemProvider);
    final notifier = ref.read(handleOrderItemProvider.notifier);
    final services = state.serviceTypes;

    final hasSelection =
        state.selectedServiceTypeId != null || state.isCustomServiceMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  context.tr('service_type_title'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '(Opsional)',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (hasSelection)
              GestureDetector(
                onTap: () {
                  notifier.selectServiceType(null, null);
                  notifier.setCustomServiceName(null);
                  if (state.isCustomServiceMode) {
                    notifier.toggleCustomServiceMode();
                  }
                  _customServiceController.clear();
                },
                child: Text(
                  context.tr('cancel'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (services.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...services.map((service) {
                final isSelected =
                    state.selectedServiceTypeId == service.id &&
                    !state.isCustomServiceMode;
                return _buildSelectableCard(
                  label: service.name,
                  isSelected: isSelected,
                  onTap: () =>
                      notifier.selectServiceType(service.id, service.name),
                );
              }),
              _buildSelectableCard(
                label: 'Lainnya (Kustom)',
                isSelected: state.isCustomServiceMode,
                onTap: () {
                  notifier.toggleCustomServiceMode();
                  if (state.isCustomServiceMode) {
                    _customServiceController.clear();
                  }
                },
              ),
            ],
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Tidak ada jenis layanan tersedia',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        if (state.isCustomServiceMode) ...[
          const SizedBox(height: 10),
          TextField(
            controller: _customServiceController,
            decoration: InputDecoration(
              hintText:
                  'Tulis nama jenis layanan khusus (cth: Bordir, Pasang Kancing, dll)',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.textHint,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (v) {
              notifier.setCustomServiceName(
                v.trim().isEmpty ? null : v.trim(),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSelectableCard({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
