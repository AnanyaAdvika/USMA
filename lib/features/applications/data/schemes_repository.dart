import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/failures.dart';
import '../domain/models/scheme_model.dart';
import 'scheme_catalog.dart';

abstract class ISchemesRepository {
  Future<List<SchemeModel>> getSchemes();
  Future<SchemeModel> getSchemeById(String id);
}

/// Both modes read scheme rules from assets/data/schemes.json.
class AssetSchemesRepository implements ISchemesRepository {
  AssetSchemesRepository(this._catalog);

  final SchemeCatalog _catalog;

  @override
  Future<List<SchemeModel>> getSchemes() => _catalog.load();

  @override
  Future<SchemeModel> getSchemeById(String id) => _catalog.byId(id);
}

final schemeCatalogProvider = Provider<SchemeCatalog>((ref) {
  return SchemeCatalog();
});

final schemesRepositoryProvider = Provider<ISchemesRepository>((ref) {
  return AssetSchemesRepository(ref.watch(schemeCatalogProvider));
});

final schemesListProvider = FutureProvider<List<SchemeModel>>((ref) {
  return ref.watch(schemesRepositoryProvider).getSchemes();
});

final schemeDetailProvider =
    FutureProvider.family<SchemeModel?, String>((ref, id) async {
  try {
    return await ref.watch(schemesRepositoryProvider).getSchemeById(id);
  } on NotFoundFailure {
    return null;
  }
});

/// Exposed so UI can label catalog origin.
bool get schemesUseSimulatedCatalog => AppConfig.isDemo;
