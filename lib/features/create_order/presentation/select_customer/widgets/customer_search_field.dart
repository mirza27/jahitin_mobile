import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations_ext.dart';
import '../../../model/customer_contact.dart';
import '../../create_order/create_order_provider.dart';
import '../select_customer_provider.dart';
import '../select_customer_state.dart';

class CustomerSearchField extends ConsumerStatefulWidget {
  const CustomerSearchField({super.key});

  @override
  ConsumerState<CustomerSearchField> createState() =>
      _CustomerSearchFieldState();
}

class _CustomerSearchFieldState extends ConsumerState<CustomerSearchField> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<CustomerContact> _filteredCustomers = [];
  bool _isSearching = false;
  bool _isFiltering = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _focusNode.addListener(() {
      setState(() {
        _isSearching = _focusNode.hasFocus && _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      _debounce?.cancel();
      setState(() {
        _filteredCustomers = [];
        _isSearching = false;
        _isFiltering = false;
      });
      return;
    }

    // Show searching state immediately for responsive feedback
    setState(() {
      _isSearching = true;
      _isFiltering = true;
    });

    // Debounce the actual filtering to avoid blocking on every keystroke
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final customers = ref.read(selectCustomerProvider).customers;
      final lowerQuery = query.toLowerCase();
      final results = customers.where((customer) {
        return customer.displayName.toLowerCase().contains(lowerQuery) ||
            customer.phoneNumber.contains(lowerQuery);
      }).toList();

      setState(() {
        _filteredCustomers = results;
        _isFiltering = false;
      });
    });
  }

  void _selectCustomer(CustomerContact customer) {
    ref.read(selectCustomerProvider.notifier).selectCustomer(customer);
    ref.read(createOrderProvider.notifier).selectCustomer(customer);
    _searchController.clear();
    _focusNode.unfocus();
    setState(() {
      _isSearching = false;
      _filteredCustomers = [];
    });
  }

  void _showAddCustomerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.surface,
        title: Text(dialogContext.tr('dialog_add_customer_title')),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(
                  nameController,
                  dialogContext.tr('customer_fullname_label'),
                  dialogContext.tr('customer_name_required'),
                ),
                const SizedBox(height: 12),
                _dialogField(
                  phoneController,
                  dialogContext.tr('customer_phone_label'),
                  dialogContext.tr('customer_phone_required'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: dialogContext.tr('customer_address_label'),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(dialogContext.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              final customer = ref
                  .read(selectCustomerProvider.notifier)
                  .createCustomer(
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    address: addressController.text.trim().isEmpty
                        ? null
                        : addressController.text.trim(),
                  );
              ref.read(createOrderProvider.notifier).selectCustomer(customer);
              _searchController.clear();
              _focusNode.unfocus();
              Navigator.pop(dialogContext);
            },
            child: Text(dialogContext.tr('btn_save_and_select')),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(
    TextEditingController controller,
    String label,
    String error, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          value == null || value.trim().isEmpty ? error : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(selectCustomerProvider);
    final selectedCustomer = customerState.selectedCustomer;
    final isLoading = customerState.status == SelectCustomerStatus.loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        context.tr('customer'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (isLoading) ...[
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('customer_subtitle'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddCustomerDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: Text(context.tr('new_customer')),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (selectedCustomer != null)
          _buildSelectedCustomerCard(selectedCustomer)
        else
          _buildSearchInput(context),
        if (_isSearching && selectedCustomer == null) _buildSuggestionsList(context),
      ],
    );
  }

  Widget _buildSearchInput(BuildContext context) {
    return TextField(
      controller: _searchController,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: context.tr('customer_search_hint'),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: _searchController.clear,
              ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSelectedCustomerCard(CustomerContact customer) {
    return Card(
      color: AppColors.surface,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            customer.displayName.isNotEmpty
                ? customer.displayName[0].toUpperCase()
                : '?',
          ),
        ),
        title: Text(customer.displayName),
        subtitle: Text(customer.phoneNumber),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(selectCustomerProvider.notifier).clearCustomer();
            ref.read(createOrderProvider.notifier).clearCustomer();
            _searchController.clear();
          },
        ),
      ),
    );
  }

  Widget _buildSuggestionsList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: _isFiltering
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          : _filteredCustomers.isEmpty
              ? ListTile(
                  title: Text(context.tr('customer_not_found')),
                  trailing: TextButton(
                    onPressed: () => _showAddCustomerDialog(context),
                    child: Text(context.tr('add_new')),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredCustomers.length,
                  separatorBuilder: (_, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final customer = _filteredCustomers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          customer.displayName.isNotEmpty
                              ? customer.displayName[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(customer.displayName),
                      subtitle: Text(customer.phoneNumber),
                      onTap: () => _selectCustomer(customer),
                    );
                  },
                ),
    );
  }
}
