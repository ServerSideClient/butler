enum InferenceIntent {
  alarm, weather;

  static InferenceIntent? fromString(String string) {
    try {
      return values.firstWhere((e) => e.name == string);
    } on StateError {
      return null;
    }
  }
}