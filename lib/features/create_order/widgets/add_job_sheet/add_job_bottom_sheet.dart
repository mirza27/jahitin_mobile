import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations_ext.dart';
import '../../../../core/models/job_item.dart';
import '../../../detail_order/model/update_detail_order.dart';
import 'step_a_service_selection.dart';

class AddJobBottomSheet extends StatefulWidget {
  final JobItem? existingJob;
  final String defaultRecipientName;
  final List<ClothesCategoryModel> categories;
  final List<ServiceTypeModel> serviceTypes;

  const AddJobBottomSheet({
    super.key,
    this.existingJob,
    required this.defaultRecipientName,
    this.categories = const [],
    this.serviceTypes = const [],
  });

  static Future<JobItem?> show(
    BuildContext context, {
    JobItem? existingJob,
    required String defaultRecipientName,
    List<ClothesCategoryModel> categories = const [],
    List<ServiceTypeModel> serviceTypes = const [],
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
          categories: categories,
          serviceTypes: serviceTypes,
        ),
      ),
    );
  }

  @override
  State<AddJobBottomSheet> createState() => _AddJobBottomSheetState();
}

class _AddJobBottomSheetState extends State<AddJobBottomSheet> {
  // --- Clothes Category (dari API atau kustom) ---
  int? _selectedCategoryId;
  String? _categoryName;
  String? _customCategoryName;

  // --- Service Type (dari API atau kustom) ---
  int? _selectedServiceTypeId;
  String? _serviceName;
  String? _customServiceName;

  // --- Penerima & Biaya & Catatan ---
  late String _recipientName;
  double? _estimatedCost;
  String? _notes;

  @override
  void initState() {
    super.initState();
    final job = widget.existingJob;
    if (job != null) {
      _selectedCategoryId = job.categoryId;
      _categoryName = job.categoryName;
      _customCategoryName = job.customCategoryName;
      _selectedServiceTypeId = job.serviceTypeId;
      _serviceName = job.serviceNameExplicit;
      _customServiceName = job.customServiceName;
      _recipientName = job.recipientName;
      _estimatedCost = job.estimatedCost;
      _notes = job.notes;
    } else {
      _recipientName = widget.defaultRecipientName;
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
              child: StepAServiceSelection(
                categories: widget.categories,
                serviceTypes: widget.serviceTypes,
                selectedCategoryId: _selectedCategoryId,
                categoryName: _categoryName,
                selectedServiceTypeId: _selectedServiceTypeId,
                serviceName: _serviceName,
                customServiceName: _customServiceName,
                recipientName: _recipientName,
                customCategoryName: _customCategoryName,
                initialCost: _estimatedCost,
                initialNotes: _notes,
                onCategorySelected: (result) => setState(() {
                  _selectedCategoryId = result.id;
                  _categoryName = result.name;
                }),
                onServiceTypeSelected: (result) => setState(() {
                  _selectedServiceTypeId = result.id;
                  _serviceName = result.name;
                }),
                onCustomServiceNameChanged: (v) =>
                    setState(() => _customServiceName = v),
                onRecipientChanged: (v) =>
                    setState(() => _recipientName = v),
                onCustomCategoryChanged: (v) =>
                    setState(() => _customCategoryName = v),
                onSave: (data) {
                  final finalJob = JobItem(
                    id: widget.existingJob?.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    categoryId: _selectedCategoryId,
                    categoryName: _selectedCategoryId != null
                        ? _categoryName
                        : null,
                    customCategoryName: _customCategoryName,
                    serviceTypeId: _selectedServiceTypeId,
                    serviceNameExplicit: _selectedServiceTypeId != null
                        ? _serviceName
                        : null,
                    customServiceName: _customServiceName,
                    recipientName: _recipientName.isNotEmpty
                        ? _recipientName
                        : widget.defaultRecipientName,
                    measurements: const BodyMeasurement(),
                    estimatedCost: data.cost,
                    notes: data.notes,
                    referencePhotoPaths: const [],
                  );
                  Navigator.of(context).pop(finalJob);
                },
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
                icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
