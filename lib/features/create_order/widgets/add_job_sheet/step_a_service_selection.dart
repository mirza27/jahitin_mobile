import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations_ext.dart';
import '../../../detail_order/model/update_detail_order.dart';

class StepAServiceSelection extends StatefulWidget {
  final List<ClothesCategoryModel> categories;
  final List<ServiceTypeModel> serviceTypes;
  final int? selectedCategoryId;
  final String? categoryName;
  final int? selectedServiceTypeId;
  final String? serviceName;
  final String? customServiceName;
  final String recipientName;
  final String? customCategoryName;
  final double? initialCost;
  final String? initialNotes;

  final ValueChanged<({int? id, String? name})> onCategorySelected;
  final ValueChanged<({int? id, String? name})> onServiceTypeSelected;
  final ValueChanged<String?> onCustomServiceNameChanged;
  final ValueChanged<String> onRecipientChanged;
  final ValueChanged<String?> onCustomCategoryChanged;
  final ValueChanged<({double cost, String? notes})> onSave;

  const StepAServiceSelection({
    super.key,
    this.categories = const [],
    this.serviceTypes = const [],
    this.selectedCategoryId,
    this.categoryName,
    this.selectedServiceTypeId,
    this.serviceName,
    this.customServiceName,
    required this.recipientName,
    this.customCategoryName,
    this.initialCost,
    this.initialNotes,
    required this.onCategorySelected,
    required this.onServiceTypeSelected,
    required this.onCustomServiceNameChanged,
    required this.onRecipientChanged,
    required this.onCustomCategoryChanged,
    required this.onSave,
  });

  @override
  State<StepAServiceSelection> createState() => _StepAServiceSelectionState();
}

class _StepAServiceSelectionState extends State<StepAServiceSelection> {
  late final TextEditingController _recipientController;
  late final TextEditingController _customCategoryController;
  late final TextEditingController _customServiceController;
  late final TextEditingController _costController;
  late final TextEditingController _notesController;

  bool _isCustomServiceMode = false;
  bool _isCustomCategoryMode = false;

  // Fallback icon helper untuk kategori
  static IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('gamis') || lower.contains('dress') || lower.contains('gaun')) {
      return Icons.checkroom_outlined;
    } else if (lower.contains('kemeja') || lower.contains('shirt')) {
      return Icons.dry_cleaning_outlined;
    } else if (lower.contains('celana') || lower.contains('pant') || lower.contains('trouser')) {
      return Icons.accessibility_new_outlined;
    } else if (lower.contains('rok') || lower.contains('skirt')) {
      return Icons.woman_outlined;
    } else if (lower.contains('jas') || lower.contains('suit') || lower.contains('blazer')) {
      return Icons.business_center_outlined;
    } else if (lower.contains('kebaya')) {
      return Icons.spa_outlined;
    } else if (lower.contains('kaos') || lower.contains('t-shirt') || lower.contains('polo')) {
      return Icons.local_laundry_service_outlined;
    }
    return Icons.style_outlined;
  }

  // Fallback icon helper untuk jenis layanan
  static IconData _getServiceIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('jahit') || lower.contains('buat') || lower.contains('baru')) {
      return Icons.content_cut;
    } else if (lower.contains('permak') || lower.contains('alter') || lower.contains('potong')) {
      return Icons.auto_fix_high;
    }
    return Icons.design_services_outlined;
  }

  @override
  void initState() {
    super.initState();
    _recipientController = TextEditingController(text: widget.recipientName);
    _customCategoryController = TextEditingController(
      text: widget.customCategoryName ?? '',
    );
    _customServiceController = TextEditingController(
      text: widget.customServiceName ?? '',
    );
    _costController = TextEditingController(
      text: widget.initialCost != null && widget.initialCost! > 0
          ? widget.initialCost!.toStringAsFixed(0)
          : '',
    );
    _notesController = TextEditingController(text: widget.initialNotes ?? '');

    _isCustomServiceMode = (widget.customServiceName != null &&
            widget.customServiceName!.isNotEmpty) ||
        (widget.selectedServiceTypeId == null &&
            widget.customServiceName != null &&
            widget.customServiceName!.isNotEmpty);

    _isCustomCategoryMode = (widget.customCategoryName != null &&
            widget.customCategoryName!.isNotEmpty) &&
        widget.selectedCategoryId == null;
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _customCategoryController.dispose();
    _customServiceController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? _parseDouble(TextEditingController controller) {
    final text = controller.text.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  bool get _canProceed {
    if (_isCustomCategoryMode && _customCategoryController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  void _submit() {
    widget.onRecipientChanged(_recipientController.text.trim());
    final cost = _parseDouble(_costController) ?? 0.0;
    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    widget.onSave((cost: cost, notes: notes));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ----------------------------------------------------
        // 1. JENIS LAYANAN (SERVICE TYPE) - List Card (Opsional)
        // ----------------------------------------------------
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
            if (widget.selectedServiceTypeId != null ||
                (widget.customServiceName != null &&
                    widget.customServiceName!.isNotEmpty))
              GestureDetector(
                onTap: () {
                  widget.onServiceTypeSelected((id: null, name: null));
                  widget.onCustomServiceNameChanged(null);
                  _customServiceController.clear();
                  setState(() {
                    _isCustomServiceMode = false;
                  });
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
        _buildServiceTypeSection(context),

        const SizedBox(height: 20),

        // ----------------------------------------------------
        // 2. KATEGORI PAKAIAN (CLOTHES CATEGORY) - List Card (Opsional)
        // ----------------------------------------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  context.tr('garment_category_title'),
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
            if (widget.selectedCategoryId != null ||
                (widget.customCategoryName != null &&
                    widget.customCategoryName!.isNotEmpty))
              GestureDetector(
                onTap: () {
                  widget.onCategorySelected((id: null, name: null));
                  widget.onCustomCategoryChanged(null);
                  _customCategoryController.clear();
                  setState(() {
                    _isCustomCategoryMode = false;
                  });
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
        _buildCategorySection(context),

        const SizedBox(height: 20),

        // ----------------------------------------------------
        // 3. UNTUK SIAPA (RECIPIENT) - Opsional
        // ----------------------------------------------------
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
          controller: _recipientController,
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
            widget.onRecipientChanged(v);
            setState(() {});
          },
        ),

        const SizedBox(height: 20),

        // ----------------------------------------------------
        // 4. ESTIMASI BIAYA
        // ----------------------------------------------------
        Text(
          context.tr('estimated_cost_title'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _costController,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ----------------------------------------------------
        // 5. CATATAN KHUSUS (JOB SPECIFIC NOTES)
        // ----------------------------------------------------
        Text(
          context.tr('job_specific_notes_title'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: context.tr('job_specific_notes_hint'),
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
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
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 28),

        // ----------------------------------------------------
        // 6. TOMBOL SIMPAN PEKERJAAN
        // ----------------------------------------------------
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
            onPressed: _canProceed ? _submit : null,
            child: Text(
              context.tr('btn_save_job'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // WIDGET SERVICE TYPE (API / KUSTOM)
  // ==========================================
  Widget _buildServiceTypeSection(BuildContext context) {
    final services = widget.serviceTypes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (services.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...services.map((service) {
                final isSelected = widget.selectedServiceTypeId == service.id &&
                    !_isCustomServiceMode;
                return _buildSelectableCard(
                  label: service.name,
                  icon: _getServiceIcon(service.name),
                  isSelected: isSelected,
                  onTap: () {
                    if (isSelected) {
                      widget.onServiceTypeSelected((id: null, name: null));
                    } else {
                      widget.onServiceTypeSelected(
                        (id: service.id, name: service.name),
                      );
                      widget.onCustomServiceNameChanged(null);
                      _customServiceController.clear();
                      setState(() {
                        _isCustomServiceMode = false;
                      });
                    }
                  },
                );
              }),
              _buildSelectableCard(
                label: 'Lainnya (Kustom)',
                icon: Icons.edit_note_outlined,
                isSelected: _isCustomServiceMode,
                onTap: () {
                  setState(() {
                    if (_isCustomServiceMode) {
                      _isCustomServiceMode = false;
                      widget.onCustomServiceNameChanged(null);
                      _customServiceController.clear();
                    } else {
                      _isCustomServiceMode = true;
                      widget.onServiceTypeSelected((id: null, name: null));
                    }
                  });
                },
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildSelectableCard(
                  label: context.tr('service_new_tailoring'),
                  icon: Icons.content_cut,
                  isSelected: widget.selectedServiceTypeId == 1 &&
                      !_isCustomServiceMode,
                  onTap: () {
                    if (widget.selectedServiceTypeId == 1) {
                      widget.onServiceTypeSelected((id: null, name: null));
                    } else {
                      widget.onServiceTypeSelected(
                        (id: 1, name: 'Jahit Baru'),
                      );
                      widget.onCustomServiceNameChanged(null);
                      setState(() => _isCustomServiceMode = false);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSelectableCard(
                  label: context.tr('service_alteration'),
                  icon: Icons.auto_fix_high,
                  isSelected: widget.selectedServiceTypeId == 2 &&
                      !_isCustomServiceMode,
                  onTap: () {
                    if (widget.selectedServiceTypeId == 2) {
                      widget.onServiceTypeSelected((id: null, name: null));
                    } else {
                      widget.onServiceTypeSelected(
                        (id: 2, name: 'Permak'),
                      );
                      widget.onCustomServiceNameChanged(null);
                      setState(() => _isCustomServiceMode = false);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              _buildSelectableCard(
                label: 'Kustom',
                icon: Icons.edit_note_outlined,
                isSelected: _isCustomServiceMode,
                onTap: () {
                  setState(() {
                    _isCustomServiceMode = !_isCustomServiceMode;
                    if (!_isCustomServiceMode) {
                      widget.onCustomServiceNameChanged(null);
                      _customServiceController.clear();
                    } else {
                      widget.onServiceTypeSelected((id: null, name: null));
                    }
                  });
                },
              ),
            ],
          ),

        if (_isCustomServiceMode) ...[
          const SizedBox(height: 10),
          TextField(
            controller: _customServiceController,
            decoration: InputDecoration(
              hintText: 'Tulis nama jenis layanan khusus (cth: Bordir, Pasang Kancing, dll)',
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
              prefixIcon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
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
              widget.onCustomServiceNameChanged(
                v.trim().isEmpty ? null : v.trim(),
              );
              setState(() {});
            },
          ),
        ],
      ],
    );
  }

  // ==========================================
  // WIDGET CLOTHES CATEGORY (API / KUSTOM)
  // ==========================================
  Widget _buildCategorySection(BuildContext context) {
    final categories = widget.categories;

    if (categories.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              if (index < categories.length) {
                final cat = categories[index];
                final isSelected = widget.selectedCategoryId == cat.id &&
                    !_isCustomCategoryMode;
                return _buildCategoryGridTile(
                  label: cat.name,
                  icon: _getCategoryIcon(cat.name),
                  isSelected: isSelected,
                  onTap: () {
                    if (isSelected) {
                      widget.onCategorySelected((id: null, name: null));
                    } else {
                      widget.onCategorySelected((id: cat.id, name: cat.name));
                      widget.onCustomCategoryChanged(null);
                      _customCategoryController.clear();
                      setState(() {
                        _isCustomCategoryMode = false;
                      });
                    }
                  },
                );
              } else {
                return _buildCategoryGridTile(
                  label: context.tr('category_other'),
                  icon: Icons.more_horiz,
                  isSelected: _isCustomCategoryMode,
                  onTap: () {
                    setState(() {
                      if (_isCustomCategoryMode) {
                        _isCustomCategoryMode = false;
                        widget.onCustomCategoryChanged(null);
                        _customCategoryController.clear();
                      } else {
                        _isCustomCategoryMode = true;
                        widget.onCategorySelected((id: null, name: null));
                      }
                    });
                  },
                );
              }
            },
          ),
          if (_isCustomCategoryMode) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _customCategoryController,
              decoration: InputDecoration(
                hintText: context.tr('custom_category_hint'),
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
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: _fallbackCategoryDefs.length,
          itemBuilder: (context, index) {
            final cat = _fallbackCategoryDefs[index];
            final isSelected = widget.selectedCategoryId == cat.id &&
                !_isCustomCategoryMode;
            return _buildCategoryGridTile(
              label: context.tr(cat.labelKey),
              icon: cat.icon,
              isSelected: isSelected,
              onTap: () {
                if (cat.id == 8) {
                  setState(() {
                    _isCustomCategoryMode = !_isCustomCategoryMode;
                    if (!_isCustomCategoryMode) {
                      widget.onCustomCategoryChanged(null);
                      _customCategoryController.clear();
                    } else {
                      widget.onCategorySelected((id: null, name: null));
                    }
                  });
                } else {
                  if (isSelected) {
                    widget.onCategorySelected((id: null, name: null));
                  } else {
                    widget.onCategorySelected(
                      (id: cat.id, name: context.tr(cat.labelKey)),
                    );
                    widget.onCustomCategoryChanged(null);
                    _customCategoryController.clear();
                    setState(() => _isCustomCategoryMode = false);
                  }
                }
              },
            );
          },
        ),
        if (_isCustomCategoryMode) ...[
          const SizedBox(height: 10),
          TextField(
            controller: _customCategoryController,
            decoration: InputDecoration(
              hintText: context.tr('custom_category_hint'),
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
      ],
    );
  }

  Widget _buildSelectableCard({
    required String label,
    required IconData icon,
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGridTile({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _fallbackCategoryDefs = [
    (id: 1, labelKey: 'category_gamis', icon: Icons.checkroom_outlined),
    (id: 2, labelKey: 'category_shirt', icon: Icons.dry_cleaning_outlined),
    (id: 3, labelKey: 'category_pants', icon: Icons.accessibility_new_outlined),
    (id: 4, labelKey: 'category_skirt', icon: Icons.woman_outlined),
    (id: 5, labelKey: 'category_suit', icon: Icons.business_center_outlined),
    (id: 6, labelKey: 'category_kebaya', icon: Icons.spa_outlined),
    (id: 7, labelKey: 'category_tshirt', icon: Icons.local_laundry_service_outlined),
    (id: 8, labelKey: 'category_other', icon: Icons.more_horiz),
  ];
}
