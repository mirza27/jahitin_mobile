import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations_ext.dart';
import '../../create_order_item/screens/create_order_detail_screen.dart';
import '../create_order_provider.dart';
import '../../select_customer/widgets/customer_search_field.dart';
import '../../select_customer/select_customer_provider.dart';
import '../../select_customer/select_customer_state.dart';
import '../widgets/deadline_picker_section.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final TextEditingController _orderNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _permissionChecked = false;

  @override
  void initState() {
    super.initState();
    final currentOrderName = ref.read(createOrderProvider).orderName;
    _orderNameController.text = currentOrderName;
    _orderNameController.addListener(() {
      ref
          .read(createOrderProvider.notifier)
          .updateOrderName(_orderNameController.text);
    });

    final currentNotes = ref.read(createOrderProvider).notes;
    _notesController.text = currentNotes;
    _notesController.addListener(() {
      ref.read(createOrderProvider.notifier).updateNotes(_notesController.text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_orderNameController.text.trim().isEmpty) {
        final defaultName = context.tr('default_order_name');
        _orderNameController.text = defaultName;
        ref.read(createOrderProvider.notifier).updateOrderName(defaultName);
      }
      _requestContactPermission();
    });
  }

  Future<void> _requestContactPermission() async {
    await ref.read(selectCustomerProvider.notifier).checkAndLoadContacts();
    if (!mounted) return;
    setState(() {
      _permissionChecked = true;
    });
  }

  @override
  void dispose() {
    _orderNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createOrderProvider);

    ref.listen<SelectCustomerState>(selectCustomerProvider, (previous, next) {
      if (!_permissionChecked) return;
      if (next.contactPermission == ContactPermission.denied ||
          next.contactPermission == ContactPermission.permanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('contact_permission_denied')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.tr('new_order'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              context.tr('step_1_of_2'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('order_name'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('order_name_subtitle'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _orderNameController,
                      decoration: InputDecoration(
                        hintText: context.tr('order_name_hint'),
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textHint,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
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
                    ),
                    const SizedBox(height: 24),
                    const CustomerSearchField(),
                    const SizedBox(height: 24),
                    const DeadlinePickerSection(),
                    const SizedBox(height: 24),
                    Text(
                      context.tr('order_notes_title'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('order_notes_subtitle'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: context.tr('order_notes_hint'),
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textHint,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
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
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomAction(context, state.isValid),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, bool isValid) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isValid ? AppColors.primary : AppColors.border,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.border,
            disabledForegroundColor: AppColors.textHint,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: isValid
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateOrderDetailScreen(),
                    ),
                  );
                }
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.tr('btn_continue_to_detail'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
