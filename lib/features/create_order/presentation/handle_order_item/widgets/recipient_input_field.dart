import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations_ext.dart';
import '../handle_order_item_provider.dart';

class RecipientInputField extends ConsumerStatefulWidget {
  const RecipientInputField({super.key});

  @override
  ConsumerState<RecipientInputField> createState() =>
      _RecipientInputFieldState();
}

class _RecipientInputFieldState extends ConsumerState<RecipientInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initialRecipient = ref.read(handleOrderItemProvider).recipientName;
    _controller = TextEditingController(text: initialRecipient);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sinkronisasi jika state di-inisialisasi ulang setelah initState
    ref.listen(handleOrderItemProvider.select((s) => s.recipientName),
        (previous, next) {
      if (_controller.text != next) {
        _controller.text = next;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('recipient_title'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.tr('recipient_subtitle'),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: context.tr('recipient_hint'),
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.surface,
            prefixIcon: const Icon(Icons.person_outline, size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
            ref.read(handleOrderItemProvider.notifier).setRecipientName(v);
          },
        ),
      ],
    );
  }
}
