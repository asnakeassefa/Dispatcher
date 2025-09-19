enum AppFlavor { development, production }

class FlavorConfig {
  FlavorConfig._(this.flavor, {required this.name, required this.baseUrl});

  static FlavorConfig? _instance;

  final AppFlavor flavor;
  final String name;
  final String baseUrl;

  static FlavorConfig get instance {
    final value = _instance;
    if (value == null) {
      throw StateError(
        'FlavorConfig not initialized. Call FlavorConfig.initialize() in main().',
      );
    }
    return value;
  }

  static void initialize({
    required AppFlavor flavor,
    required String name,
    required String baseUrl,
  }) {
    _instance = FlavorConfig._(flavor, name: name, baseUrl: baseUrl);
  }

  bool get isDevelopment => flavor == AppFlavor.development;
  bool get isProduction => flavor == AppFlavor.production;
}
