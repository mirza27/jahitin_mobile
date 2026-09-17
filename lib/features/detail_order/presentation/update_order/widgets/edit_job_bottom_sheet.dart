import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../model/update_detail_order.dart';

class EditJobBottomSheet extends StatefulWidget {
  final UpdateOrderItem? initialItem;
  final List<ClothesCategoryModel> categories;
  final List<ServiceTypeModel> serviceTypes;
  final String defaultClothesFor;

  const EditJobBottomSheet({
    super.key,
    this.initialItem,
    required this.categories,
    required this.serviceTypes,
    required this.defaultClothesFor,
  });

  static Future<UpdateOrderItem?> show(
    BuildContext context, {
    UpdateOrderItem? initialItem,
    required List<ClothesCategoryModel> categories,
    required List<ServiceTypeModel> serviceTypes,
    required String defaultClothesFor,
  }) {
    return showModalBottomSheet<UpdateOrderItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EditJobBottomSheet(
          initialItem: initialItem,
          categories: categories,
          serviceTypes: serviceTypes,
          defaultClothesFor: defaultClothesFor,
        ),
      ),
    );
  }

  @override
  State<EditJobBottomSheet> createState() => _EditJobBottomSheetState();
}

class _EditJobBottomSheetState extends State<EditJobBottomSheet> {
  late final TextEditingController _clothesCategoryController;
  late final TextEditingController _clothesForController;
  late final TextEditingController _customServiceController;
  late final TextEditingController _notesController;
  late final TextEditingController _priceController;

  int? _selectedCategoryId;
  String? _selectedCategoryName;

  int? _selectedServiceId;
  String? _selectedServiceName;
  bool _isCustomService = false;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;

    _clothesForController = TextEditingController(
      text: item?.clothesFor ?? widget.defaultClothesFor,
    );
    _notesController = TextEditingController(text: item?.notes ?? '');
    _priceController = TextEditingController(
      text: item != null && item.price > 0 ? item.price.toInt().toString() : '',
    );
    _customServiceController = TextEditingController(
      text: item?.customServiceName ?? '',
    );

    // Kategori
    if (item?.categoryId != null) {
      _selectedCategoryId = int.tryParse(item!.categoryId!);
    }
    _selectedCategoryName = item?.categoryName;
    _clothesCategoryController = TextEditingController(
      text: _selectedCategoryName ?? '',
    );

    // Service Type
    if (item?.serviceId != null && item!.serviceId!.isNotEmpty) {
      _selectedServiceId = int.tryParse(item.serviceId!);
      _selectedServiceName = item.serviceName;
    }
    if (item?.customServiceName != null && item!.customServiceName!.isNotEmpty) {
      _isCustomService = true;
    }
  }

  @override
  void dispose() {
    _clothesCategoryController.dispose();
    _clothesForController.dispose();
    _customServiceController.dispose();
    _notesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onCategorySelected(ClothesCategoryModel cat) {
    setState(() {
      _selectedCategoryId = cat.id;
      _selectedCategoryName = cat.name;
      _clothesCategoryController.text = cat.name;
    });
  }

  void _onServiceSelected(ServiceTypeModel service) {
    setState(() {
      _selectedServiceId = service.id;
      _selectedServiceName = service.name;
      _isCustomService = false;
      _customServiceController.clear();
    });
  }

  void _onSelectLainnyaService() {
    setState(() {
      _selectedServiceId = null;
      _selectedServiceName = 'Lainnya';
      _isCustomService = true;
    });
  }

  void _save() {
    final priceVal = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final clothesForVal = _clothesForController.text.trim();
    final notesVal = _notesController.text.trim();
    final customServiceVal = _customServiceController.text.trim();

    final result = UpdateOrderItem(
      localId: widget.initialItem?.localId ??
          'item_${DateTime.now().millisecondsSinceEpoch}',
      clothesFor: clothesForVal.isNotEmpty ? clothesForVal : null,
      notes: notesVal.isNotEmpty ? notesVal : null,
      serviceId: _selectedServiceId?.toString(),
      serviceName: _isCustomService ? 'Lainnya' : _selectedServiceName,
      customServiceName: _isCustomService && customServiceVal.isNotEmpty
          ? customServiceVal
          : null,
      categoryId: _selectedCategoryId?.toString(),
      categoryName: _clothesCategoryController.text.trim().isNotEmpty
          ? _clothesCategoryController.text.trim()
          : _selectedCategoryName,
      price: priceVal,
      status: widget.initialItem?.status ?? 'pending',
      saveCustomerNotes: widget.initialItem?.saveCustomerNotes ?? false,
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialItem != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdit ? 'Edit Pekerjaan' : 'Tambah Pekerjaan',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.divider, height: 1),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Jenis Barang (Text field & Kategori picker)
                  const Text(
                    'Jenis Barang',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _clothesCategoryController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Gamis, Celana, Baju Anak...',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textHint,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
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
                  ),

                  // Opsi cepat Kategori Pakaian dari API
                  if (widget.categories.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: widget.categories.map((cat) {
                          final isSelected = _selectedCategoryId == cat.id ||
                              _clothesCategoryController.text.trim().toLowerCase() ==
                                  cat.name.toLowerCase();
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(
                                cat.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) => _onCategorySelected(cat),
                              backgroundColor: AppColors.background,
                              selectedColor: AppColors.primaryLight,
                              checkmarkColor: AppColors.primary,
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 2. Jenis Pekerjaan (Chips)
                  const Text(
                    'Jenis Pekerjaan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildServiceChips(),

                  if (_isCustomService) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _customServiceController,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan jenis pekerjaan...',
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
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 3. Untuk Siapa
                  const Text(
                    'Untuk Siapa (Opsional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _clothesForController,
                    decoration: InputDecoration(
                      hintText: 'Nama penerima pakaian (contoh: Bu Siti)',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textHint,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
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
                  ),

                  const SizedBox(height: 20),

                  // 4. Catatan (Opsional)
                  const Text(
                    'Catatan (Opsional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Misalnya: Resleting putih, hati-hati kain, dll',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textHint,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
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
                  ),

                  const SizedBox(height: 20),

                  // 5. Biaya (Opsional)
                  const Text(
                    'Biaya (Opsional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      prefixIcon: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Text(
                          'Rp',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      hintText: '50000',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textHint,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
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
                  ),

                  const SizedBox(height: 28),

                  // Tombol Simpan/Update Pekerjaan
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _save,
                      child: Text(
                        isEdit ? 'Update Pekerjaan' : 'Tambah Pekerjaan',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChips() {
    // Default fallback list jika API belum me-load
    final fallbackServices = [
      'Jahit baru',
      'Kecilkan',
      'Besarkan',
      'Pendekkan',
      'Ganti resleting',
      'Obras',
      'Tambal',
      'Lainnya',
    ];

    if (widget.serviceTypes.isEmpty) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: fallbackServices.map((label) {
          final isLainnya = label == 'Lainnya';
          final isSelected = isLainnya
              ? _isCustomService
              : (!_isCustomService &&
                  _selectedServiceName?.toLowerCase() == label.toLowerCase());
          return _buildChip(
            label: label,
            isSelected: isSelected,
            onTap: () {
              if (isLainnya) {
                _onSelectLainnyaService();
              } else {
                setState(() {
                  _selectedServiceName = label;
                  _isCustomService = false;
                  _customServiceController.clear();
                });
              }
            },
          );
        }).toList(),
      );
    }

    final hasLainnya = widget.serviceTypes.any(
      (s) => s.name.toLowerCase() == 'lainnya',
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...widget.serviceTypes.map((service) {
          final isSelected =
              !_isCustomService && _selectedServiceId == service.id;
          return _buildChip(
            label: service.name,
            isSelected: isSelected,
            onTap: () => _onServiceSelected(service),
          );
        }),
        if (!hasLainnya)
          _buildChip(
            label: 'Lainnya',
            isSelected: _isCustomService,
            onTap: _onSelectLainnyaService,
          ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFEFF5F8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
