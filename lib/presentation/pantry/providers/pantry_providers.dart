import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/sqlite_pantry_repository.dart';
import '../../../data/services/csu_invoice_parsing_service.dart';
import '../../../data/services/invoice_parsing_service.dart';
import '../../../domain/entities/pantry_item.dart';
import '../../../domain/repositories/pantry_repository.dart';
import '../../auth/providers/auth_providers.dart';

final pantryRepositoryProvider = Provider<PantryRepository>((ref) {
  return SqlitePantryRepository();
});

/// Real (non-mocked) PDF text parser for Costa Rican "Tiquete Electrónico"
/// supermarket receipts — see [CsuInvoiceParsingService]. For other
/// receipt formats, add a new [InvoiceParsingService] implementation (e.g.
/// an OCR/vision-based one behind a backend proxy) and swap it in here.
final invoiceParsingServiceProvider = Provider<InvoiceParsingService>((ref) {
  return CsuInvoiceParsingService();
});

class PantryController extends StateNotifier<AsyncValue<List<PantryItem>>> {
  PantryController(this._repository, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      reload();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  final PantryRepository _repository;
  final int? _userId;

  Future<void> reload() async {
    if (_userId == null) return;
    state = await AsyncValue.guard(() => _repository.allItems(_userId));
  }

  Future<void> addItem(PantryItem item) async {
    await _repository.addItem(item);
    await reload();
  }

  Future<void> addItems(List<PantryItem> items) async {
    for (final item in items) {
      await _repository.addItem(item);
    }
    await reload();
  }

  /// Replaces the entire pantry with [items] — used when saving a scanned
  /// invoice: every prior item (from an earlier invoice scan or added
  /// manually) is deleted first, so the pantry always reflects only the
  /// most recent invoice rather than accumulating stale/duplicate stock
  /// across shopping trips. This is intentionally destructive; the invoice
  /// review screen warns the user before calling it.
  Future<void> replaceAllWithInvoiceItems(List<PantryItem> items) async {
    if (_userId == null) return;
    await _repository.deleteAllItems(_userId);
    for (final item in items) {
      await _repository.addItem(item);
    }
    await reload();
  }

  Future<void> updateItem(PantryItem item) async {
    await _repository.updateItem(item);
    await reload();
  }

  Future<void> deleteItem(int itemId) async {
    await _repository.deleteItem(itemId);
    await reload();
  }
}

final pantryControllerProvider =
    StateNotifierProvider<PantryController, AsyncValue<List<PantryItem>>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return PantryController(ref.watch(pantryRepositoryProvider), userId);
});
