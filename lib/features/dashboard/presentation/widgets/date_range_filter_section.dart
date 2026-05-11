import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../expenses/domain/models/date_range_filter_model.dart';
import '../../../expenses/presentation/providers/date_filter_provider.dart';

class DateRangeFilterSection
    extends ConsumerWidget {
  const DateRangeFilterSection({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final selectedRange =
        ref.watch(
      selectedDateRangeProvider,
    );

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final pickedRange =
                  await showDateRangePicker(
                context: context,
                firstDate:
                    DateTime(2020),
                lastDate:
                    DateTime.now(),
                initialDateRange:
                    selectedRange ==
                            null
                        ? null
                        : DateTimeRange(
                            start:
                                selectedRange
                                    .startDate,
                            end:
                                selectedRange
                                    .endDate,
                          ),
              );

              if (pickedRange !=
                  null) {
                ref
                    .read(
                      selectedDateRangeProvider
                          .notifier,
                    )
                    .state =
                    DateRangeFilterModel(
                  startDate:
                      pickedRange
                          .start,
                  endDate:
                      pickedRange
                          .end,
                );
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.date_range,
                    color:
                        AppColors.primary,
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Text(
                      selectedRange ==
                              null
                          ? 'Select Date Range'
                          : '${DateFormat('dd MMM').format(selectedRange.startDate)} - ${DateFormat('dd MMM yyyy').format(selectedRange.endDate)}',
                      overflow:
                          TextOverflow
                              .ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (selectedRange != null)
          Padding(
            padding:
                const EdgeInsets.only(
              left: 12,
            ),
            child: GestureDetector(
              onTap: () {
                ref
                    .read(
                      selectedDateRangeProvider
                          .notifier,
                    )
                    .state = null;
              },
              child: Container(
                padding:
                    const EdgeInsets.all(
                  14,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.red,
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child: const Icon(
                  Icons.close,
                  color:
                      Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}