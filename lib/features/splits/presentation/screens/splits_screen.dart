import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../domain/utils/friend_balance_calculator.dart';
import '../widgets/friend_balance_tile.dart';

class SplitsScreen extends ConsumerWidget {
  const SplitsScreen({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final expenses = ref.watch(
      expensesProvider,
    );

    final balances =
        FriendBalanceCalculator
            .calculateBalances(
      expenses,
    );

    final totalPending =
        FriendBalanceCalculator
            .calculateTotalPending(
      expenses,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Splits',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                24,
              ),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  28,
                ),
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xFFF59E0B),
                    Color(0xFFF97316),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Text(
                    'Pending Receivables',
                    style: TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    '₹${totalPending.toStringAsFixed(0)}',
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 36,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            const Text(
              'People',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            Expanded(
              child: balances.isEmpty
                  ? const Center(
                      child: Text(
                        'No pending splits',
                      ),
                    )
                  : ListView.builder(
                      itemCount:
                          balances.length,
                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        return FriendBalanceTile(
                          balance:
                              balances[
                                  index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}