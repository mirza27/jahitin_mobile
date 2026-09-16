import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';

class PaymentBreakdownCard extends StatefulWidget {
  final double totalCost;
  final double downPayment;
  final double remainingBalance;
  final ValueChanged<double> onDownPaymentChanged;

  const PaymentBreakdownCard({
    super.key,
    required this.totalCost,
    required this.downPayment,
    required this.remainingBalance,
    required this.onDownPaymentChanged,
  });

  @override
  State<PaymentBreakdownCard> createState() => _PaymentBreakdownCardState();
}

class _PaymentBreakdownCardState extends State<PaymentBreakdownCard> {
  late final TextEditingController _dpController;

  @override
  void initState() {
    super.initState();
    _dpController = TextEditingController(
      text: widget.downPayment > 0 ? widget.downPayment.toStringAsFixed(0) : '',
    );
  }

  @override
  void didUpdateWidget(covariant PaymentBreakdownCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.downPayment != widget.downPayment) {
      final currentParsed = double.tryParse(_dpController.text) ?? 0.0;
      if (currentParsed != widget.downPayment) {
        _dpController.text = widget.downPayment > 0
            ? widget.downPayment.toStringAsFixed(0)
            : '';
      }
    }
  }

  @override
  void dispose() {
    _dpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Biaya',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              Text(
                currencyFormatter.format(widget.totalCost),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                flex: 4,
                child: Text(
                  'Uang Muka / DP',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _dpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(
                      prefixText: 'Rp ',
                      prefixStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      hintText: '0',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textHint,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      final parsed =
                          double.tryParse(val.replaceAll('.', '').trim()) ??
                          0.0;
                      widget.onDownPaymentChanged(parsed);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sisa Pembayaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                currencyFormatter.format(widget.remainingBalance),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
