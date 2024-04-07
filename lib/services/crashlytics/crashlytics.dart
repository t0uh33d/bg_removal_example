class Crashlytics {
  static final Crashlytics i = Crashlytics._i();

  Crashlytics._i();

  factory Crashlytics() => i;

  void traceError(Object error, StackTrace stack) {}
}
