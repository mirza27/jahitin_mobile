import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class BottomActionBar extends StatelessWidget {
  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onCreateOrder;
  final VoidCallback onSaveDraft;

  const BottomActionBar({
    super.key,
    required this.canSubmit,
    required this.isSubmitting,
    required this.onCreateOrder,
    required this.onSaveDraft,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: isSubmitting ? null : onSaveDraft,
              child: const Text(
                'Simpan Draft',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canSubmit
                    ? AppColors.primary
                    : AppColors.border,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                disabledForegroundColor: AppColors.textHint,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: (canSubmit && !isSubmitting) ? onCreateOrder : null,
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Buat Pesanan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
