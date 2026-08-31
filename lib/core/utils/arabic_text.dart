/// Arabic-aware text utilities for GazaLook.
///
/// Arabic shoppers type the same word many ways: with or without diacritics
/// (تشكيل), with different forms of alef (أ إ آ ا), taa marbuta vs. haa
/// (ة/ه), alef maqsura vs. yaa (ى/ي), or stretched with tatweel (ـ). A naive
/// `contains` check misses those, so searching "فستان" would not find a
/// product stored as "فُستان". [ArabicText.normalize] folds all of these to a
/// single canonical form so search and matching are forgiving — mirroring the
/// Arabic-normalized search that makes the catalogue easy to browse.
abstract final class ArabicText {
  const ArabicText._();

  /// Arabic diacritics (harakat) and the tatweel/kashida elongation mark.
  ///
  /// Covers fathatan…sukun (U+064B–U+0652), superscript alef (U+0670) and the
  /// tatweel (U+0640).
  static final RegExp _diacritics =
      RegExp('[ـً-ْٰ]');

  /// Canonicalises [input] for search and equality checks.
  ///
  /// Trims and lower-cases (so Latin text matches too), strips diacritics and
  /// tatweel, unifies alef/taa-marbuta/alef-maqsura variants, and collapses
  /// internal whitespace to single spaces.
  static String normalize(String input) {
    final String stripped = input
        .trim()
        .toLowerCase()
        .replaceAll(_diacritics, '')
        // Alef family → bare alef.
        .replaceAll('أ', 'ا') // أ
        .replaceAll('إ', 'ا') // إ
        .replaceAll('آ', 'ا') // آ
        .replaceAll('ٱ', 'ا') // ٱ (alef wasla)
        // Taa marbuta → haa.
        .replaceAll('ة', 'ه') // ة → ه
        // Alef maqsura → yaa.
        .replaceAll('ى', 'ي') // ى → ي
        // Hamza carriers on waw/yaa → plain letter.
        .replaceAll('ؤ', 'و') // ؤ → و
        .replaceAll('ئ', 'ي'); // ئ → ي

    // Collapse runs of whitespace (incl. those left by removed tatweel).
    return stripped.replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Whether [haystack] contains [needle], ignoring Arabic form differences,
  /// diacritics and case.
  static bool containsNormalized(String haystack, String needle) {
    final String n = normalize(needle);
    if (n.isEmpty) return true;
    return normalize(haystack).contains(n);
  }
}
