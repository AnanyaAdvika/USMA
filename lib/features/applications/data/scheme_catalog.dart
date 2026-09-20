import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/errors/failures.dart';
import '../domain/models/mota_scheme_model.dart';
import '../domain/models/scheme_model.dart';

class SchemeCatalog {
  SchemeCatalog({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  List<MotaSchemeModel>? _motaCache;
  List<SchemeModel>? _cache;

  Future<List<MotaSchemeModel>> loadMotaSchemes() async {
    if (_motaCache != null) return _motaCache!;
    try {
      final raw = await _bundle.loadString('assets/data/schemes.json');
      final decoded = json.decode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const ParseFailure('Scheme catalog is not a JSON object.');
      }
      final list = decoded['schemes'];
      if (list is! List) {
        throw const ParseFailure('Scheme catalog is missing the schemes list.');
      }
      _motaCache = list
          .map((e) => MotaSchemeModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      return _motaCache!;
    } on Failure {
      rethrow;
    } on FormatException catch (e) {
      throw ParseFailure('Scheme catalog JSON is invalid: ${e.message}');
    }
  }

  Future<List<SchemeModel>> load() async {
    if (_cache != null) return _cache!;
    final motaList = await loadMotaSchemes();
    _cache = motaList.map((m) => SchemeModel.fromMotaScheme(m)).toList();
    return _cache!;
  }

  Future<MotaSchemeModel> motaSchemeById(String id) async {
    final schemes = await loadMotaSchemes();
    for (final scheme in schemes) {
      if (scheme.schemeId == id ||
          (scheme.schemeId == 'pre_matric_st' && id == 'pre_matric') ||
          (scheme.schemeId == 'post_matric_st' && id == 'post_matric') ||
          (scheme.schemeId == 'top_class_st' && id == 'top_class')) {
        return scheme;
      }
    }
    throw NotFoundFailure('Scheme "$id" was not found in the official catalog.');
  }

  Future<SchemeModel> byId(String id) async {
    final schemes = await load();
    for (final scheme in schemes) {
      if (scheme.id == id ||
          (scheme.id == 'pre_matric_st' && id == 'pre_matric') ||
          (scheme.id == 'post_matric_st' && id == 'post_matric') ||
          (scheme.id == 'top_class_st' && id == 'top_class')) {
        return scheme;
      }
    }
    throw NotFoundFailure('Scheme "$id" was not found in the catalog.');
  }
}
