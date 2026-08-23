import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/models/category_spending_model.dart';

class CategoryPieChart
    extends StatelessWidget {
  final List<CategorySpendingModel>
      categories;

  const CategoryPieChart({
    super.key,
    required this.categories,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    if (categories.isEmpty) {
      return const SizedBox();
    }

    return SizedBox(
      height: 260,
      child: PieChart(
        PieChartData(
          sectionsSpace: 3,
          centerSpaceRadius:
              50,
          sections:
              List.generate(
            categories.length
                .clamp(
              0,
              5,
            ),
            (index) {
              final category =
                  categories[
                      index];

              return PieChartSectionData(
                value:
                    category.amount,
                radius: 70,
                title:
                    '${category.amount.toInt()}',
              );
            },
          ),
        ),
      ),
    );
  }
}