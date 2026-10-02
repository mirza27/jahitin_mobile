import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations_ext.dart';
import '../handle_order_item_provider.dart';

class CostInputField extends ConsumerStatefulWidget {
  const CostInputField({super.key});

  @override
  ConsumerState<CostInputField> createState() => _CostInputFieldState();
}

class _CostInputFieldState extends ConsumerState<CostInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final cost = ref.read(handleOrderItemProvider).cost;
    _controller = TextEditingController(
      text: cost != null && cost > 0 ? cost.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? _parseDouble(String text) {
    final cleaned = text.trim().replaceAll(',', '.');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(handleOrderItemProvider.select((s) => s.cost), (prev, next) {
      final formattedNext = next != null && next > 0 ? next.toStringAsFixed(0) : '';
      if (_controller.text != formattedNext) {
        _controller.text = formattedNext;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.tr('cost_optional_title'),
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
        const SizedBox(height: 4),
        Text(
          context.tr('cost_optional_subtitle'),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: 'Rp  ',
            prefixStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            hintText: '0',
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
          onChanged: (v) {
            final parsedCost = _parseDouble(v);
            ref.read(handleOrderItemProvider.notifier).setCost(parsedCost);
          },
        ),
      ],
    );
  }
}
