import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/imported_transaction.dart';

class ImportedTransactionCard
    extends StatelessWidget {
  final ImportedTransaction
      transaction;

  final VoidCallback? onDelete;

  const ImportedTransactionCard({
    super.key,
    required this.transaction,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDebit =
        transaction.type ==
            ImportedTransactionType
                .debit;

    final merchant =
        transaction.merchant
                ?.trim()
                .isNotEmpty ==
            true
        ? transaction.merchant!
        : transaction.upiId ??
            'Unknown merchant';

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          24,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration:
                BoxDecoration(
              color: isDebit
                  ? AppColors.softDanger
                  : AppColors.softSuccess,
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),
            child: Icon(
              isDebit
                  ? Icons
                      .arrow_upward_rounded
                  : Icons
                      .arrow_downward_rounded,
              color: isDebit
                  ? AppColors.danger
                  : AppColors.success,
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  merchant,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w700,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  _subtitle(),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        AppColors
                            .textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .end,
            children: [
              Text(
                '${isDebit ? '-' : '+'}₹${transaction.amount.toStringAsFixed(0)}',
                style:
                    TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  color: isDebit
                      ? AppColors
                          .textPrimary
                      : AppColors
                          .success,
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              _statusBadge(),
            ],
          ),
        ],
      ),
    );
  }

  String _subtitle() {
    final date =
        transaction.transactionDate;

    final dateString =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    if (transaction.bankName !=
            null &&
        transaction.bankName!
            .trim()
            .isNotEmpty) {
      return '${transaction.bankName} • $dateString';
    }

    return dateString;
  }

  Widget _statusBadge() {
    String label;
    Color color;
    Color background;

    switch (transaction.status) {
      case ImportedTransactionStatus
            .pending:
        label = 'Pending';
        color =
            AppColors.warning;
        background =
            AppColors.softWarning;
        break;

      case ImportedTransactionStatus
            .processed:
        label = 'Added';
        color =
            AppColors.success;
        background =
            AppColors.softSuccess;
        break;

      case ImportedTransactionStatus
            .ignored:
        label = 'Ignored';
        color =
            AppColors.danger;
        background =
            AppColors.softDanger;
        break;

     
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        label,
        style:
            TextStyle(
          fontSize: 11,
          fontWeight:
              FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}