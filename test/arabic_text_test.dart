import 'package:flutter_test/flutter_test.dart';
import 'package:gazalook/core/utils/arabic_text.dart';

void main() {
  group('ArabicText.normalize', () {
    test('unifies alef variants', () {
      expect(ArabicText.normalize('أحمر'), ArabicText.normalize('احمر'));
      expect(ArabicText.normalize('إسدال'), ArabicText.normalize('اسدال'));
      expect(ArabicText.normalize('آية'), ArabicText.normalize('ايه'));
    });

    test('folds taa marbuta and alef maqsura', () {
      expect(ArabicText.normalize('عباية'), ArabicText.normalize('عبايه'));
      expect(ArabicText.normalize('مصطفى'), ArabicText.normalize('مصطفي'));
    });

    test('strips diacritics and tatweel', () {
      expect(ArabicText.normalize('فُسْتان'), 'فستان');
      expect(ArabicText.normalize('فســـتان'), 'فستان');
    });

    test('collapses whitespace and lower-cases latin', () {
      expect(ArabicText.normalize('  Abaya   Black '), 'abaya black');
    });
  });

  group('ArabicText.containsNormalized', () {
    test('matches across spelling variants', () {
      expect(ArabicText.containsNormalized('فستان سهرة أحمر', 'سهره احمر'),
          isTrue);
      expect(ArabicText.containsNormalized('عبايه سوداء', 'عباية'), isTrue);
    });

    test('empty needle matches anything', () {
      expect(ArabicText.containsNormalized('anything', ''), isTrue);
    });

    test('non-matching needle returns false', () {
      expect(ArabicText.containsNormalized('فستان', 'حذاء'), isFalse);
    });
  });
}
