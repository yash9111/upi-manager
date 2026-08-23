import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/models/monthly_spending_model.dart';

class MonthlyTrendChart
    extends StatelessWidget {
  final List<MonthlySpendingModel>
      data;

  const MonthlyTrendChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox();
    }

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          borderData:
              FlBorderData(
            show: false,
          ),
          gridData:
              FlGridData(
            show: false,
          ),
          titlesData:
              FlTitlesData(
            show: false,
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              spots: List.generate(
                data.length,
                (index) {
                  return FlSpot(
                    index
                        .toDouble(),
                    data[index]
                        .amount,
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