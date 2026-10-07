import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jahitin_mobile/core/models/clothes_category.dart';
import 'package:jahitin_mobile/core/models/service_type.dart';
import 'package:jahitin_mobile/features/create_order/model/create_order_item.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations_ext.dart';
import 'handle_order_item_provider.dart';
import 'widgets/clothes_category_selector.dart';
import 'widgets/cost_input_field.dart';
import 'widgets/notes_input_field.dart';
import 'widgets/recipient_input_field.dart';
import 'widgets/service_type_selector.dart';

class HandleOrderItemBottomSheet extends ConsumerStatefulWidget {
  final CreateOrderItem? existingOrderItem;
  final String defaultRecipientName;
  final List<ClothesCategoryModel> categories;
  final List<ServiceTypeModel> serviceTypes;
  final bool isFirstItem;

  const HandleOrderItemBottomSheet({
    super.key,
    this.existingOrderItem,
    required this.defaultRecipientName,
    this.categories = const [],
    this.serviceTypes = const [],
    this.isFirstItem = true,
  });

  static Future<CreateOrderItem?> show(
    BuildContext context, {
    CreateOrderItem? existingOrderItem,
    required String defaultRecipientName,
    List<ClothesCategoryModel> categories = const [],
    List<ServiceTypeModel> serviceTypes = const [],
    bool isFirstItem = true,
  }) {
    return showModalBottomSheet<CreateOrderItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: HandleOrderItemBottomSheet(
          existingOrderItem: existingOrderItem,
          defaultRecipientName: defaultRecipientName,
          categories: categories,
          serviceTypes: serviceTypes,
          isFirstItem: isFirstItem,
        ),
      ),
    );
  }

  @override
  ConsumerState<HandleOrderItemBottomSheet> createState() =>
      _HandleOrderItemBottomSheetState();
}

class _HandleOrderItemBottomSheetState
    extends ConsumerState<HandleOrderItemBottomSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(handleOrderItemProvider.notifier)
          .initialize(
            existingItem: widget.existingOrderItem,
            defaultRecipient: widget.defaultRecipientName,
            categories: widget.categories,
            serviceTypes: widget.serviceTypes,
          );
    });
  }

  void _submit() {
    final state = ref.read(handleOrderItemProvider);
    final result = state.toCreateOrderItem(
      fallbackRecipient: widget.defaultRecipientName,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingOrderItem != null;
    final title = isEdit ? context.tr('edit_job') : context.tr('add_job');

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, title),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const RecipientInputField(),
                  const SizedBox(height: 20),
                  const ServiceTypeSelector(),
                  const SizedBox(height: 20),
                  const ClothesCategorySelector(),
                  const SizedBox(height: 20),
                  const CostInputField(),
                  const SizedBox(height: 20),
                  NotesInputField(isFirstItem: widget.isFirstItem),
                  const SizedBox(height: 28),
                  _buildSubmitButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _submit,
        child: Text(
          context.tr('btn_save_job'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
