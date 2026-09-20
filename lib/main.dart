import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/constants/firebase_options.dart';
import 'core/errors/error_mapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (AppConfig.isLive) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  } else {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (e) {
      debugPrint('SIMULATED: Firebase not required in demo (${e.code}).');
    } on Object catch (e) {
      debugPrint('SIMULATED: Firebase skipped in demo ($e).');
    }
  }

  runApp(
    const ProviderScope(
      child: UsmaApp(),
    ),
  );
}
