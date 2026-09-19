import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations_ext.dart';
import '../../../../core/models/job_item.dart';

class StepBMeasurementsForm extends StatefulWidget {
  final BodyMeasurement initialMeasurements;
  final double? initialCost;
  final String? initialNotes;
  final List<String> initialPhotoPaths;
  final VoidCallback onBack;
  final ValueChanged<JobItemData> onSave;

  const StepBMeasurementsForm({
    super.key,
    required this.initialMeasurements,
    this.initialCost,
    this.initialNotes,
    this.initialPhotoPaths = const [],
    required this.onBack,
    required this.onSave,
  });

  @override
  State<StepBMeasurementsForm> createState() => _StepBMeasurementsFormState();
}

class JobItemData {
  final BodyMeasurement measurements;
  final double estimatedCost;
  final String? notes;
  final List<String> photoPaths;

  const JobItemData({
    required this.measurements,
    required this.estimatedCost,
    this.notes,
    this.photoPaths = const [],
  });
}

class _StepBMeasurementsFormState extends State<StepBMeasurementsForm> {
  late final TextEditingController _lingkarDadaController;
  late final TextEditingController _panjangLenganController;
  late final TextEditingController _panjangBajuController;
  late final TextEditingController _lingkarPinggangController;
  late final TextEditingController _lebarBahuController;
  late final TextEditingController _lingkarPinggulController;
  late final TextEditingController _costController;
  late final TextEditingController _notesController;
  late List<String> _photoPaths;

  @override
  void initState() {
    super.initState();
    final m = widget.initialMeasurements;
    _lingkarDadaController = TextEditingController(
        text: m.lingkarDada != null ? m.lingkarDada!.toStringAsFixed(0) : '');
    _panjangLenganController = TextEditingController(
        text: m.panjangLengan != null ? m.panjangLengan!.toStringAsFixed(0) : '');
    _panjangBajuController = TextEditingController(
        text: m.panjangBaju != null ? m.panjangBaju!.toStringAsFixed(0) : '');
    _lingkarPinggangController = TextEditingController(
        text: m.lingkarPinggang != null ? m.lingkarPinggang!.toStringAsFixed(0) : '');
    _lebarBahuController = TextEditingController(
        text: m.lebarBahu != null ? m.lebarBahu!.toStringAsFixed(0) : '');
    _lingkarPinggulController = TextEditingController(
        text: m.lingkarPinggul != null ? m.lingkarPinggul!.toStringAsFixed(0) : '');

    _costController = TextEditingController(
        text: widget.initialCost != null && widget.initialCost! > 0
            ? widget.initialCost!.toStringAsFixed(0)
            : '');
    _notesController = TextEditingController(text: widget.initialNotes ?? '');
    _photoPaths = List.from(widget.initialPhotoPaths);
  }

  @override
  void dispose() {
    _lingkarDadaController.dispose();
    _panjangLenganController.dispose();
    _panjangBajuController.dispose();
    _lingkarPinggangController.dispose();
    _lebarBahuController.dispose();
    _lingkarPinggulController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? _parseDouble(TextEditingController controller) {
    final text = controller.text.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  void _submit() {
    final measurements = BodyMeasurement(
      lingkarDada: _parseDouble(_lingkarDadaController),
      panjangLengan: _parseDouble(_panjangLenganController),
      panjangBaju: _parseDouble(_panjangBajuController),
      lingkarPinggang: _parseDouble(_lingkarPinggangController),
      lebarBahu: _parseDouble(_lebarBahuController),
      lingkarPinggul: _parseDouble(_lingkarPinggulController),
    );

    final cost = _parseDouble(_costController) ?? 0.0;
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    widget.onSave(
      JobItemData(
        measurements: measurements,
        estimatedCost: cost,
        notes: notes,
        photoPaths: _photoPaths,
      ),
    );
  }

  void _addMockPhoto() {
    setState(() {
      _photoPaths.add('photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
              onPressed: widget.onBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Text(
              context.tr('body_measurements_title'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          context.tr('body_measurements_subtitle'),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),
        _buildMeasurementGrid(context),
        const SizedBox(height: 20),
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
        Text(
          context.tr('reference_photos_title'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.tr('reference_photos_subtitle'),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        _buildPhotoSection(context),
        const SizedBox(height: 20),
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
        const SizedBox(height: 24),
        SizedBox(
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
        ),
      ],
    );
  }

  Widget _buildMeasurementGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMeasurementInput(
                label: context.tr('measurement_bust'),
                controller: _lingkarDadaController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMeasurementInput(
                label: context.tr('measurement_sleeve_length'),
                controller: _panjangLenganController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMeasurementInput(
                label: context.tr('measurement_dress_length'),
                controller: _panjangBajuController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMeasurementInput(
                label: context.tr('measurement_waist'),
                controller: _lingkarPinggangController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMeasurementInput(
                label: context.tr('measurement_shoulder_width'),
                controller: _lebarBahuController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMeasurementInput(
                label: context.tr('measurement_hip'),
                controller: _lingkarPinggulController,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeasurementInput({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            suffixText: 'cm',
            suffixStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            hintText: '0',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GestureDetector(
            onTap: _addMockPhoto,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined, size: 24, color: AppColors.primary),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('add_photo_btn'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          ..._photoPaths.map(
            (path) => Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.image, color: AppColors.primary, size: 32),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _photoPaths.remove(path);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
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
}
