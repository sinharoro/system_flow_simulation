class TransactionModel {
  final String id;
  final String name;
  final double amount;
  final DateTime date;
  final String category;
  final String logoEmoji;
  final bool isPositive;

  const TransactionModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
    required this.logoEmoji,
    required this.isPositive,
  });
}

class AssetModel {
  final String id;
  final String name;
  final String symbol;
  final double balance;
  final double value;
  final double change24h;
  final String emoji;
  final List<double> chartData;

  const AssetModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.balance,
    required this.value,
    required this.change24h,
    required this.emoji,
    required this.chartData,
  });
}

class PortfolioModel {
  final double totalBalance;
  final double dailyChange;
  final double dailyChangePercent;
  final List<double> weeklyChartData;

  const PortfolioModel({
    required this.totalBalance,
    required this.dailyChange,
    required this.dailyChangePercent,
    required this.weeklyChartData,
  });
}