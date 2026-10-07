import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations_ext.dart';
import '../handle_order_item_provider.dart';

class NotesInputField extends ConsumerStatefulWidget {
  final bool isFirstItem;

  const NotesInputField({
    super.key,
    this.isFirstItem = true,
  });

  @override
  ConsumerState<NotesInputField> createState() => _NotesInputFieldState();
}

class _NotesInputFieldState extends ConsumerState<NotesInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initialNotes = ref.read(handleOrderItemProvider).notes;
    _controller = TextEditingController(text: initialNotes ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(handleOrderItemProvider.select((s) => s.notes), (prev, next) {
      final text = next ?? '';
      if (_controller.text != text) {
        _controller.text = text;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.tr('notes_optional_title'),
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
          context.tr('notes_optional_subtitle'),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: context.tr('notes_optional_hint'),
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
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
            ref.read(handleOrderItemProvider.notifier).setNotes(
                  v.trim().isEmpty ? null : v.trim(),
                );
          },
        ),
        if (widget.isFirstItem) ...[
          const SizedBox(height: 10),
          Consumer(
            builder: (context, ref, child) {
              final saveCustomerNotes = ref.watch(
                handleOrderItemProvider.select((s) => s.saveCustomerNotes),
              );
              return InkWell(
                onTap: () {
                  ref
                      .read(handleOrderItemProvider.notifier)
                      .setSaveCustomerNotes(!saveCustomerNotes);
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: saveCustomerNotes,
                          onChanged: (value) {
                            ref
                                .read(handleOrderItemProvider.notifier)
                                .setSaveCustomerNotes(value ?? false);
                          },
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('save_customer_notes_title'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.tr('save_customer_notes_subtitle'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
