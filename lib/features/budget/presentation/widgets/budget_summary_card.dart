import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class BudgetSummaryCard
    extends StatelessWidget {
  final double totalBudget;

  final double totalSpent;

  const BudgetSummaryCard({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final remaining =
        totalBudget - totalSpent;

    final progress =
        totalBudget == 0
            ? 0.0
            : (totalSpent / totalBudget)
                .clamp(0.0, 1.0);

    final percent =
        (progress * 100)
            .toStringAsFixed(0);

    return Container(
      padding:
          const EdgeInsets.all(
        24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          32,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.all(
                  12,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      AppColors
                          .softPrimary,
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
                child: const Icon(
                  Icons
                      .account_balance_wallet_outlined,
                  color:
                      AppColors
                          .primary,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'Budget Overview',
                      style:
                          TextStyle(
                        fontSize:
                            20,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Current month spending',
                      style:
                          TextStyle(
                        color:
                            AppColors
                                .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal:
                      14,
                  vertical: 8,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      AppColors
                          .softPrimary,
                  borderRadius:
                      BorderRadius.circular(
                    30,
                  ),
                ),
                child: Text(
                  '$percent%',
                  style:
                      const TextStyle(
                    color:
                        AppColors
                            .primary,
                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 28,
          ),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            child:
                LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor:
                  AppColors.border,
            ),
          ),

          const SizedBox(
            height: 26,
          ),

          Row(
            children: [
              Expanded(
                child:
                    buildMetricCard(
                  title:
                      'Spent',
                  value:
                      '₹${totalSpent.toStringAsFixed(0)}',
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child:
                    buildMetricCard(
                  title:
                      remaining >= 0
                          ? 'Remaining'
                          : 'Overspent',
                  value:
                      '₹${remaining.abs().toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMetricCard({
    required String title,
    required String value,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration: BoxDecoration(
        color:
            AppColors.background,
        borderRadius:
            BorderRadius.circular(
          24,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color:
                  AppColors
                      .textSecondary,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}