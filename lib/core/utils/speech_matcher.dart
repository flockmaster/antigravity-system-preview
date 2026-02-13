/// Utility class for speech recognition matching logic.
/// Handles text normalization and comparison strategy.
class SpeechMatcher {
  /// Evaluate if the recognized text matches the target word/phrase.
  /// 
  /// Returns [true] if the [target] is significantly present in [recognized].
  /// Supports fuzzy matching by:
  /// - Case insensitivity
  /// - Removing punctuation
  /// - Allowing partial matches (target inside result)
  bool evaluate(String recognized, String target) {
    if (recognized.isEmpty || target.isEmpty) return false;

    final normalizedRecognized = _normalize(recognized);
    final normalizedTarget = _normalize(target);

    // 1. Exact match (fastest)
    if (normalizedRecognized == normalizedTarget) return true;

    // 2. Contains match (e.g. "I said apple" matches "apple")
    if (normalizedRecognized.contains(normalizedTarget)) return true;

    // 3. Reverse contains (rare, e.g. "apple" matches "an apple" if ASR cuts off)
    // Actually ASR cutoff usually means fail, so maybe skip this.
    
    // 4. Fuzzy fallback (optional, currently strictly logical)
    // Could add Levenshtein distance here if needed.
    
    return false;
  }

  /// Normalize text: lowercase, remove punctuation, trim extra spaces
  String _normalize(String text) {
    return text.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' ')    // Merge spaces
        .trim();                            // Trim ends
  }
}
