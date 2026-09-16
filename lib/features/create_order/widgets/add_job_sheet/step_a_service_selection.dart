import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/job_item.dart';
import 'garment_category_chip.dart';

class StepAServiceSelection extends StatefulWidget {
  final ServiceType serviceType;
  final GarmentCategory? selectedCategory;
  final String recipientName;
  final String? customCategoryName;
  final ValueChanged<ServiceType> onServiceTypeChanged;
  final ValueChanged<GarmentCategory> onCategoryChanged;
  final ValueChanged<String> onRecipientChanged;
  final ValueChanged<String?> onCustomCategoryChanged;
  final VoidCallback onNext;

  const StepAServiceSelection({
    super.key,
    required this.serviceType,
    required this.selectedCategory,
    required this.recipientName,
    required this.customCategoryName,
    required this.onServiceTypeChanged,
    required this.onCategoryChanged,
    required this.onRecipientChanged,
    required this.onCustomCategoryChanged,
    required this.onNext,
  });

  @override
  State<StepAServiceSelection> createState() => _StepAServiceSelectionState();
}

class _StepAServiceSelectionState extends State<StepAServiceSelection> {
  late final TextEditingController _recipientController;
  late final TextEditingController _customCategoryController;

  static const _categories = [
    (
      category: GarmentCategory.gamis,
      label: 'Gamis',
      icon: Icons.checkroom_outlined,
    ),
    (
      category: GarmentCategory.kemeja,
      label: 'Kemeja',
      icon: Icons.dry_cleaning_outlined,
    ),
    (
      category: GarmentCategory.celana,
      label: 'Celana',
      icon: Icons.accessibility_new_outlined,
    ),
    (category: GarmentCategory.rok, label: 'Rok', icon: Icons.woman_outlined),
    (
      category: GarmentCategory.jas,
      label: 'Jas',
      icon: Icons.business_center_outlined,
    ),
    (
      category: GarmentCategory.kebaya,
      label: 'Kebaya',
      icon: Icons.spa_outlined,
    ),
    (
      category: GarmentCategory.kaos,
      label: 'Kaos',
      icon: Icons.local_laundry_service_outlined,
    ),
    (
      category: GarmentCategory.lainnya,
      label: 'Lainnya',
      icon: Icons.more_horiz,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _recipientController = TextEditingController(text: widget.recipientName);
    _customCategoryController = TextEditingController(
      text: widget.customCategoryName ?? '',
    );
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    final hasCategory = widget.selectedCategory != null;
    final hasRecipient = _recipientController.text.trim().isNotEmpty;
    final customOk =
        widget.selectedCategory != GarmentCategory.lainnya ||
        _customCategoryController.text.trim().isNotEmpty;
    return hasCategory && hasRecipient && customOk;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Layanan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _buildServiceTypeToggle(),
        const SizedBox(height: 20),
        const Text(
          'Kategori Pakaian',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _buildCategoryGrid(),
        if (widget.selectedCategory == GarmentCategory.lainnya) ...[
          const SizedBox(height: 10),
          TextField(
            controller: _customCategoryController,
            decoration: InputDecoration(
              hintText: 'Nama kategori (contoh: Mukena, Kaftan...)',
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
              widget.onCustomCategoryChanged(
                v.trim().isEmpty ? null : v.trim(),
              );
              setState(() {});
            },
          ),
        ],
        const SizedBox(height: 20),
        const Text(
          'Untuk Siapa',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Nama penerima / pemilik pakaian ini',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _recipientController,
          decoration: InputDecoration(
            hintText: 'Contoh: Bu Siti, Anak Pertama, Pak Budi...',
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
            widget.onRecipientChanged(v);
            setState(() {});
          },
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _canProceed
                  ? AppColors.primary
                  : AppColors.border,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _canProceed
                ? () {
                    widget.onRecipientChanged(_recipientController.text.trim());
                    widget.onNext();
                  }
                : null,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Lanjut ke Ukuran & Detail',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildServiceToggleItem(
            label: 'Jahit Baru',
            icon: Icons.content_cut,
            isSelected: widget.serviceType == ServiceType.jahitBaru,
            onTap: () => widget.onServiceTypeChanged(ServiceType.jahitBaru),
          ),
          const SizedBox(width: 4),
          _buildServiceToggleItem(
            label: 'Permak',
            icon: Icons.auto_fix_high,
            isSelected: widget.serviceType == ServiceType.permak,
            onTap: () => widget.onServiceTypeChanged(ServiceType.permak),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceToggleItem({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        final isSelected = widget.selectedCategory == cat.category;
        return GarmentCategoryChip(
          label: cat.label,
          icon: cat.icon,
          isSelected: isSelected,
          onTap: () {
            widget.onCategoryChanged(cat.category);
            if (cat.category != GarmentCategory.lainnya) {
              widget.onCustomCategoryChanged(null);
              _customCategoryController.clear();
            }
            setState(() {});
          },
        );
      },
    );
  }
}
