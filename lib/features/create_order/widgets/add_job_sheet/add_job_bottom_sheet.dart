import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations_ext.dart';
import '../../../../core/models/job_item.dart';
import 'step_a_service_selection.dart';
import 'step_b_measurements_form.dart';

class AddJobBottomSheet extends StatefulWidget {
  final JobItem? existingJob;
  final String defaultRecipientName;

  const AddJobBottomSheet({
    super.key,
    this.existingJob,
    required this.defaultRecipientName,
  });

  static Future<JobItem?> show(
    BuildContext context, {
    JobItem? existingJob,
    required String defaultRecipientName,
  }) {
    return showModalBottomSheet<JobItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddJobBottomSheet(
          existingJob: existingJob,
          defaultRecipientName: defaultRecipientName,
        ),
      ),
    );
  }

  @override
  State<AddJobBottomSheet> createState() => _AddJobBottomSheetState();
}

class _AddJobBottomSheetState extends State<AddJobBottomSheet> {
  int _currentStep = 0;

  late ServiceType _serviceType;
  GarmentCategory? _selectedCategory;
  late String _recipientName;
  String? _customCategoryName;

  late BodyMeasurement _measurements;
  double? _estimatedCost;
  String? _notes;
  List<String> _photoPaths = [];

  @override
  void initState() {
    super.initState();
    final job = widget.existingJob;
    if (job != null) {
      _serviceType = job.serviceType;
      _selectedCategory = job.category;
      _recipientName = job.recipientName;
      _customCategoryName = job.customCategoryName;
      _measurements = job.measurements;
      _estimatedCost = job.estimatedCost;
      _notes = job.notes;
      _photoPaths = List.from(job.referencePhotoPaths);
    } else {
      _serviceType = ServiceType.jahitBaru;
      _selectedCategory = GarmentCategory.gamis;
      _recipientName = widget.defaultRecipientName;
      _measurements = const BodyMeasurement();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.existingJob != null
        ? context.tr('edit_job')
        : context.tr('add_job');

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
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _currentStep == 0
                    ? StepAServiceSelection(
                        key: const ValueKey('step_a'),
                        serviceType: _serviceType,
                        selectedCategory: _selectedCategory,
                        recipientName: _recipientName,
                        customCategoryName: _customCategoryName,
                        onServiceTypeChanged: (st) => setState(() => _serviceType = st),
                        onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
                        onRecipientChanged: (rec) => setState(() => _recipientName = rec),
                        onCustomCategoryChanged: (cust) => setState(() => _customCategoryName = cust),
                        onNext: () => setState(() => _currentStep = 1),
                      )
                    : StepBMeasurementsForm(
                        key: const ValueKey('step_b'),
                        initialMeasurements: _measurements,
                        initialCost: _estimatedCost,
                        initialNotes: _notes,
                        initialPhotoPaths: _photoPaths,
                        onBack: () => setState(() => _currentStep = 0),
                        onSave: (data) {
                          final finalJob = JobItem(
                            id: widget.existingJob?.id ??
                                DateTime.now().millisecondsSinceEpoch.toString(),
                            serviceType: _serviceType,
                            category: _selectedCategory ?? GarmentCategory.lainnya,
                            recipientName: _recipientName,
                            customCategoryName: _customCategoryName,
                            measurements: data.measurements,
                            estimatedCost: data.estimatedCost,
                            notes: data.notes,
                            referencePhotoPaths: data.photoPaths,
                          );
                          Navigator.of(context).pop(finalJob);
                        },
                      ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _currentStep == 0
                      ? context.tr('step_1_2')
                      : context.tr('step_2_2'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
