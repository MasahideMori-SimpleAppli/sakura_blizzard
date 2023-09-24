import 'package:flutter_test/flutter_test.dart';
import 'package:sakura_blizzard/sakura_blizzard.dart';

void main() {
  test('Sakura petal object generation test', () {
    try {
      final _ = UtilSakuraCreator.sakuraPetal(20, 30, 4);
    } catch (e) {
      expect(false, true);
    }
  });
}
