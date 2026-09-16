import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/models/customer.dart';
import '../../create_order/create_order_provider.dart';
import '../select_customer_provider.dart';

class CustomerSearchField extends ConsumerStatefulWidget {
  const CustomerSearchField({super.key});

  @override
  ConsumerState<CustomerSearchField> createState() =>
      _CustomerSearchFieldState();
}

class _CustomerSearchFieldState extends ConsumerState<CustomerSearchField> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<Customer> _filteredCustomers = [];
  bool _isSearching = false;

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
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    final customers = ref.read(selectCustomerProvider).customers;
    setState(() {
      _filteredCustomers = query.isEmpty
          ? []
          : customers.where((customer) {
              return customer.name.toLowerCase().contains(query) ||
                  customer.phone.contains(query);
            }).toList();
      _isSearching = query.isNotEmpty;
    });
  }

  void _selectCustomer(Customer customer) {
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
        title: const Text('Tambah Pelanggan Baru'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(
                  nameController,
                  'Nama Lengkap *',
                  'Nama wajib diisi',
                ),
                const SizedBox(height: 12),
                _dialogField(
                  phoneController,
                  'No. Telepon / WhatsApp *',
                  'Nomor telepon wajib diisi',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Alamat (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
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
            child: const Text('Simpan & Pilih'),
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
    final selectedCustomer = ref.watch(selectCustomerProvider).selectedCustomer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pelanggan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => _showAddCustomerDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Pelanggan Baru'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (selectedCustomer != null)
          _buildSelectedCustomerCard(selectedCustomer)
        else
          _buildSearchInput(),
        if (_isSearching && selectedCustomer == null) _buildSuggestionsList(),
      ],
    );
  }

  Widget _buildSearchInput() {
    return TextField(
      controller: _searchController,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: 'Cari nama atau no. telepon...',
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

  Widget _buildSelectedCustomerCard(Customer customer) {
    return Card(
      color: AppColors.surface,
      child: ListTile(
        leading: CircleAvatar(child: Text(customer.name[0].toUpperCase())),
        title: Text(customer.name),
        subtitle: Text(customer.phone),
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

  Widget _buildSuggestionsList() {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: _filteredCustomers.isEmpty
          ? ListTile(
              title: const Text('Pelanggan tidak ditemukan.'),
              trailing: TextButton(
                onPressed: () => _showAddCustomerDialog(context),
                child: const Text('Tambah Baru'),
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
                    child: Text(customer.name[0].toUpperCase()),
                  ),
                  title: Text(customer.name),
                  subtitle: Text(customer.phone),
                  onTap: () => _selectCustomer(customer),
                );
              },
            ),
    );
  }
}
