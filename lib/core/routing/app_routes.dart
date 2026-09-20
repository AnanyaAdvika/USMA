class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String ekyc = '/ekyc';
  
  static const String dashboard = '/dashboard';
  static const String schemes = '/schemes';
  static const String schemeDetail = '/schemes/:id';
  static const String applyScheme = '/apply/:id';
  static const String applications = '/applications';
  static const String applicationDetail = '/applications/:id';
  static const String documents = '/documents';
  static const String disbursements = '/disbursements';
  static const String eligibility = '/eligibility';
  static const String coverageGap = '/coverage-gap';
  static const String chatbot = '/chatbot';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String verification = '/verification';
  static const String adminAnalytics = '/admin-analytics';
  static const String integrationStatus = '/integration-status';
  static const String settings = '/settings';

  static String schemeDetailPath(String id) => '/schemes/$id';
  static String applySchemePath(String id) => '/apply/$id';
  static String applicationDetailPath(String id) => '/applications/$id';
}
