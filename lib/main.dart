import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/constants/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive offline storage
  await Hive.initFlutter();

  // Initialize Firebase with fallback configuration
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initializeApp notice: $e');
  }

  runApp(
    const ProviderScope(
      child: UsmaApp(),
    ),
  );
}
