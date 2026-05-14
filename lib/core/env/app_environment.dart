enum AppEnvironment {
  dev('dev'),
  staging('staging'),
  production('production');

  const AppEnvironment(this.value);

  final String value;

  static AppEnvironment fromValue(String rawValue) {
    switch (rawValue.trim().toLowerCase()) {
      case 'dev':
        return AppEnvironment.dev;
      case 'staging':
        return AppEnvironment.staging;
      case 'prod':
      case 'production':
        return AppEnvironment.production;
      default:
        return AppEnvironment.dev;
    }
  }
}
