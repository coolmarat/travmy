import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ResultsBarChart extends StatelessWidget {
  final List<String> typeOrder;
  final Map<String, int> answers;

  const ResultsBarChart({
    super.key,
    required this.typeOrder,
    required this.answers,
  });

  BarChartGroupData _generateBarGroup(
    int x,
    double value,
    Color color,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 25,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> barColors = [
      Colors.blue[200]!,
      Colors.green[200]!,
      Colors.orange[200]!,
      Colors.purple[200]!,
      Colors.red[200]!,
    ];

    final orderedEntries =
        typeOrder.map((type) => MapEntry(type, answers[type] ?? 0)).toList();

    final maxScore =
        answers.values.isEmpty ? 5 : answers.values.reduce(max);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxScore + 1).toDouble(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < orderedEntries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        orderedEntries[index].key,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 1),
              left: BorderSide(color: Colors.black, width: 1),
            ),
          ),
          barGroups: List.generate(
            orderedEntries.length,
            (index) => _generateBarGroup(
              index,
              orderedEntries[index].value.toDouble(),
              barColors[index % barColors.length],
            ),
          ),
        ),
      ),
    );
  }
}
