import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/failures.dart';
import '../domain/models/mota_scheme_model.dart';
import '../domain/models/scheme_model.dart';
import 'scheme_catalog.dart';

abstract class ISchemesRepository {
  Future<List<SchemeModel>> getSchemes();
  Future<SchemeModel> getSchemeById(String id);
  Future<List<MotaSchemeModel>> getMotaSchemes();
  Future<MotaSchemeModel> getMotaSchemeById(String id);
}

/// Fallback built-in schemes representation in case of asset read issues
class SchemesRepository {
  static List<SchemeModel> get defaultSchemes => const [];
}

/// Both modes read scheme rules from assets/data/schemes.json.
class AssetSchemesRepository implements ISchemesRepository {
  AssetSchemesRepository(this._catalog);

  final SchemeCatalog _catalog;

  @override
  Future<List<SchemeModel>> getSchemes() => _catalog.load();

  @override
  Future<SchemeModel> getSchemeById(String id) => _catalog.byId(id);

  @override
  Future<List<MotaSchemeModel>> getMotaSchemes() => _catalog.loadMotaSchemes();

  @override
  Future<MotaSchemeModel> getMotaSchemeById(String id) => _catalog.motaSchemeById(id);
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

final motaSchemesListProvider = FutureProvider<List<MotaSchemeModel>>((ref) {
  return ref.watch(schemesRepositoryProvider).getMotaSchemes();
});

final schemeDetailProvider =
    FutureProvider.family<SchemeModel?, String>((ref, id) async {
  try {
    return await ref.watch(schemesRepositoryProvider).getSchemeById(id);
  } on NotFoundFailure {
    return null;
  }
});

final motaSchemeDetailProvider =
    FutureProvider.family<MotaSchemeModel?, String>((ref, id) async {
  try {
    return await ref.watch(schemesRepositoryProvider).getMotaSchemeById(id);
  } on NotFoundFailure {
    return null;
  }
});

/// Exposed so UI can label catalog origin.
bool get schemesUseSimulatedCatalog => AppConfig.isDemo;
