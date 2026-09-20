/// Compile-time data source: `--dart-define=DATA_MODE=demo|live`.
///
/// Demo selects Mock (SIMULATED) adapters. Live selects Firebase-backed USMA
/// adapters. Government systems never have invented URLs in this client.
enum DataMode { demo, live }

class AppConfig {
  AppConfig._();

  static const String dataModeRaw = String.fromEnvironment(
    'DATA_MODE',
    defaultValue: 'demo',
  );

  static DataMode get dataMode {
    switch (dataModeRaw.toLowerCase()) {
      case 'live':
        return DataMode.live;
      default:
        return DataMode.demo;
    }
  }

  static bool get isDemo => dataMode == DataMode.demo;
  static bool get isLive => dataMode == DataMode.live;

  /// Shown in UI whenever Mock adapters are active.
  static const String simulatedLabel = 'SIMULATED';
}
