import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/errors/failures.dart';
import '../domain/models/scheme_model.dart';

class SchemeCatalog {
  SchemeCatalog({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  List<SchemeModel>? _cache;

  Future<List<SchemeModel>> load() async {
    if (_cache != null) return _cache!;
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
      _cache = list
          .map((e) => SchemeModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      return _cache!;
    } on Failure {
      rethrow;
    } on FormatException catch (e) {
      throw ParseFailure('Scheme catalog JSON is invalid: ${e.message}');
    }
  }

  Future<SchemeModel> byId(String id) async {
    final schemes = await load();
    for (final scheme in schemes) {
      if (scheme.id == id) return scheme;
    }
    throw NotFoundFailure('Scheme "$id" was not found in the catalog.');
  }
}
