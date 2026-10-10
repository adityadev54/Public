/// Backwards-compatible no-op config shim.
///
/// Theme presets now ship directly with the package, so calling [init]
/// is optional and retained only for older integrations.
class KinConfig {
  KinConfig._();

  /// Always `true`; presets are available without extra setup.
  static bool get isAuthorized => true;

  /// Retained for API compatibility with older package versions.
  static void init({required String devKey}) {}
}
