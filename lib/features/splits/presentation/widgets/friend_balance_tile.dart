import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../domain/models/friend_balance_model.dart';

class FriendBalanceTile
    extends ConsumerWidget {
  final FriendBalanceModel balance;

  const FriendBalanceTile({
    super.key,
    required this.balance,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                AppColors.warning
                    .withOpacity(0.1),
            child: Text(
              balance.name[0]
                  .toUpperCase(),
              style: const TextStyle(
                color:
                    AppColors.warning,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  balance.name,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight
                            .w600,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  '${balance.pendingTransactions} pending transaction',
                  style:
                      const TextStyle(
                    color: AppColors
                        .textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .end,
            children: [
              Text(
                '₹${balance.pendingAmount.toStringAsFixed(0)}',
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              GestureDetector(
                onTap: () async {
                  await ref
                      .read(
                        expensesProvider
                            .notifier,
                      )
                      .settleParticipant(
                        expenseId:
                            balance
                                .expenseId,
                        participantId:
                            balance
                                .participantId,
                      );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration:
                      BoxDecoration(
                    color: AppColors
                        .success,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Text(
                    'Settle',
                    style: TextStyle(
                      color:
                          Colors.white,
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
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