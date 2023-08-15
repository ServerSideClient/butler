enum Day {
  today(Duration()),
  tomorrow(Duration(days: 1));

  const Day(this.durationFromToday);

  final Duration durationFromToday;

  static Day? fromString(String string) {
    try {
      return values.firstWhere((e) => e.name == string);
    } on StateError {
      return null;
    }
  }

  static String get asOptions {
    return values.map((e) => e.name).join(" | ");
  }
}
