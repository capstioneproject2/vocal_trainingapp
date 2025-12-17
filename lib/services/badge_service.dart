import 'package:shared_preferences/shared_preferences.dart';

class BadgeService {
  static const _kBadgesKey = 'badges';

  /// 뱃지 목록 가져오기
  static Future<List<String>> getBadges() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kBadgesKey) ?? [];
  }

  /// 뱃지 추가 (중복 방지)
  static Future<void> addBadge(String badge) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kBadgesKey) ?? [];
    if (!list.contains(badge)) {
      list.add(badge);
      await prefs.setStringList(_kBadgesKey, list);
    }
  }

  /// 조건 체크해서 자동 지급
  static Future<List<String>> evaluateAndGrant({
    required int totalScore,
    required int practiceCount,
  }) async {
    final newly = <String>[];

    // 첫 기록
    if (practiceCount == 1) newly.add('🎤 New Singer');

    // 5회 연습
    if (practiceCount >= 5) newly.add('🔁 Practice Master');

    // 고득점
    if (totalScore >= 80) newly.add('🌟 Pitch Star');
    if (totalScore >= 95) newly.add('🏆 Almost Original');

    for (final b in newly) {
      await addBadge(b);
    }
    return newly;
  }
}
