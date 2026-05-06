import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/glass_card.dart';
import '../../core/constants/colors.dart';
import 'charts/line_chart.dart';
import 'widgets/action_buttons.dart';
import 'widgets/stats_row.dart';
import 'widgets/asset_scroll_view.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/pulse_dot.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late List<Animation<double>> _entryAnimations;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _entryAnimations = List.generate(6, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entryController,
          curve: Interval(
            index * 0.1,
            (0.6 + index * 0.1).clamp(0.0, 1.0),
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = ref.watch(portfolioProvider);
    final assets = ref.watch(assetsProvider);
    final transactions = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.backgroundGradient,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.backgroundGradientLeft,
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _entryAnimations[0],
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.1),
                        end: Offset.zero,
                      ).animate(_entryAnimations[0]),
                      child: _buildHeader(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _entryAnimations[1],
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(_entryAnimations[1]),
                      child: _buildBalanceCard(portfolio),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _entryAnimations[2],
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(_entryAnimations[2]),
                      child: StatsRow(assets: assets),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _entryAnimations[3],
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(_entryAnimations[3]),
                      child: _buildChart(portfolio),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _entryAnimations[4],
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(_entryAnimations[4]),
                      child: AssetScrollView(assets: assets),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _entryAnimations[5],
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(_entryAnimations[5]),
                      child: RecentTransactions(transactions: transactions),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning',
                style: TextStyle(
                  color: AppColors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppGradients.primaryGradient.createShader(bounds),
                child: const Text(
                  'Nova',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppGradients.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                '🎓',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(dynamic portfolio) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Portfolio',
              style: TextStyle(
                color: AppColors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: portfolio.totalBalance),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.ease,
              builder: (context, value, child) {
                return ShaderMask(
                  shaderCallback: (bounds) =>
                      AppGradients.primaryGradient.createShader(bounds),
                  child: Text(
                    '\$${value.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                PulseDot(isPositive: portfolio.dailyChange >= 0),
                const SizedBox(width: 8),
                Text(
                  '${portfolio.dailyChange >= 0 ? '+' : ''}\$${portfolio.dailyChange.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: portfolio.dailyChange >= 0
                        ? AppColors.success
                        : AppColors.error,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${portfolio.dailyChangePercent >= 0 ? '+' : ''}${portfolio.dailyChangePercent.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    color: portfolio.dailyChangePercent >= 0
                        ? AppColors.success
                        : AppColors.error,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  'Today',
                  style: TextStyle(
                    color: AppColors.white50,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const ActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(dynamic portfolio) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Portfolio',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '7D',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: PortfolioLineChart(data: portfolio.weeklyChartData),
            ),
          ],
        ),
      ),
    );
  }
}