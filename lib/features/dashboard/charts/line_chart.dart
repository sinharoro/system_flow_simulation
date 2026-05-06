import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PortfolioLineChart extends StatefulWidget {
  final List<double> data;

  const PortfolioLineChart({super.key, required this.data});

  @override
  State<PortfolioLineChart> createState() => _PortfolioLineChartState();
}

class _PortfolioLineChartState extends State<PortfolioLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minY = widget.data.reduce((a, b) => a < b ? a : b) * 0.95;
    final maxY = widget.data.reduce((a, b) => a > b ? a : b) * 1.05;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => const Color(0xFF7C3AED),
                tooltipRoundedRadius: 8,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '\$${spot.y.toStringAsFixed(0)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: widget.data.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    entry.value * _animation.value,
                  );
                }).toList(),
                isCurved: true,
                curveSmoothness: 0.3,
                color: const Color(0xFF7C3AED),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF7C3AED).withAlpha(77),
                      const Color(0xFF7C3AED).withAlpha(0),
                    ],
                  ),
                ),
              ),
            ],
            minY: minY,
            maxY: maxY,
          ),
        );
      },
    );
  }
}