import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/transaction_repository.dart';

final transactionRepositoryProvider = Provider((ref) => TransactionRepository());

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<TransactionModel>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionsNotifier(repository);
});

final assetsProvider = StateNotifierProvider<AssetsNotifier, List<AssetModel>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return AssetsNotifier(repository);
});

final portfolioProvider = StateNotifierProvider<PortfolioNotifier, PortfolioModel>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return PortfolioNotifier(repository);
});

class TransactionsNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionsNotifier(TransactionRepository repository) : super(repository.getTransactions());
}

class AssetsNotifier extends StateNotifier<List<AssetModel>> {
  AssetsNotifier(TransactionRepository repository) : super(repository.getAssets());
}

class PortfolioNotifier extends StateNotifier<PortfolioModel> {
  PortfolioNotifier(TransactionRepository repository) : super(repository.getPortfolio());
}