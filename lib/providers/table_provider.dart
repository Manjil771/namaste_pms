import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nhpms/models/table_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class TableState {
  final bool isLoading;
  final List<TableModel> tables;
  final String? error;

  const TableState({
    this.isLoading = false,
    this.tables = const [],
    this.error,
  });

  List<TableModel> get availableTables =>
      tables.where((t) => t.isAvailable).toList();

  TableState copyWith({
    bool? isLoading,
    List<TableModel>? tables,
    String? error,
  }) {
    return TableState(
      isLoading: isLoading ?? this.isLoading,
      tables: tables ?? this.tables,
      error: error,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class TableNotifier extends StateNotifier<TableState> {
  TableNotifier(this._ref) : super(const TableState());

  final Ref _ref;
  final _apiService = ApiService();

  Future<void> fetchTables() async {
    final businessId = _ref.read(authProvider).user?.businessId;

    if (businessId == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Business ID not found. Please log in again.',
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final raw = await _apiService.getTables(businessId);
      final tables = raw
          .map((json) => TableModel.fromJson(json as Map<String, dynamic>))
          .toList();
      state = state.copyWith(isLoading: false, tables: tables);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load tables: ${e.toString()}',
      );
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final tableProvider = StateNotifierProvider<TableNotifier, TableState>((ref) {
  return TableNotifier(ref);
});