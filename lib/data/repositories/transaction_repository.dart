import '../models/models.dart';

class TransactionRepository {
  List<TransactionModel> getTransactions() {
    return [
      TransactionModel(
        id: '1',
        name: 'Bitcoin Mining',
        amount: 1250.00,
        date: DateTime.now().subtract(const Duration(hours: 2)),
        category: 'Mining',
        logoEmoji: '⛏️',
        isPositive: true,
      ),
      TransactionModel(
        id: '2',
        name: 'ETH Transfer',
        amount: 450.50,
        date: DateTime.now().subtract(const Duration(hours: 5)),
        category: 'Transfer',
        logoEmoji: '⟳',
        isPositive: true,
      ),
      TransactionModel(
        id: '3',
        name: 'Platform Fee',
        amount: 12.99,
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Fee',
        logoEmoji: '📄',
        isPositive: false,
      ),
      TransactionModel(
        id: '4',
        name: 'NFT Purchase',
        amount: 250.00,
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: 'NFT',
        logoEmoji: '🖼️',
        isPositive: false,
      ),
      TransactionModel(
        id: '5',
        name: 'Staking Reward',
        amount: 89.25,
        date: DateTime.now().subtract(const Duration(days: 2)),
        category: 'Staking',
        logoEmoji: '🎯',
        isPositive: true,
      ),
      TransactionModel(
        id: '6',
        name: 'Token Swap',
        amount: 175.00,
        date: DateTime.now().subtract(const Duration(days: 3)),
        category: 'Swap',
        logoEmoji: '🔄',
        isPositive: true,
      ),
    ];
  }

  List<AssetModel> getAssets() {
    return [
      AssetModel(
        id: '1',
        name: 'Bitcoin',
        symbol: 'BTC',
        balance: 0.75,
        value: 32150.00,
        change24h: 2.45,
        emoji: '₿',
        chartData: [28000, 29500, 28800, 30200, 31500, 30800, 32150],
      ),
      AssetModel(
        id: '2',
        name: 'Ethereum',
        symbol: 'ETH',
        balance: 4.2,
        value: 12840.00,
        change24h: -1.23,
        emoji: 'Ξ',
        chartData: [2800, 2950, 2880, 3020, 3150, 3080, 3057],
      ),
      AssetModel(
        id: '3',
        name: 'Solana',
        symbol: 'SOL',
        balance: 25.0,
        value: 3250.00,
        change24h: 5.67,
        emoji: '◎',
        chartData: [110, 115, 120, 118, 125, 130, 132],
      ),
      AssetModel(
        id: '4',
        name: 'Cardano',
        symbol: 'ADA',
        balance: 1500.0,
        value: 675.00,
        change24h: -0.89,
        emoji: '₳',
        chartData: [0.42, 0.44, 0.43, 0.45, 0.46, 0.45, 0.44],
      ),
    ];
  }

  PortfolioModel getPortfolio() {
    return PortfolioModel(
      totalBalance: 48294.12,
      dailyChange: 1250.50,
      dailyChangePercent: 2.65,
      weeklyChartData: [42000, 43500, 42800, 45200, 46500, 45800, 48294],
    );
  }
}