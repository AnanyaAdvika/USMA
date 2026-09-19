class Env {
  static late String _environment;
  static void init() {
    _environment = const String.fromEnvironment('ENV', defaultValue: 'dev');
  }
  static String get environment => _environment;
  static bool get isDev => _environment == 'dev';
  static bool get isProd => _environment == 'prod';
}
