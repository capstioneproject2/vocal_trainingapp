import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _goToSearch(BuildContext context) {
    Navigator.pushNamed(context, '/search'); // 노래 검색하기
  }

  void _goToHistory(BuildContext context) {
    Navigator.pushNamed(context, '/mypage'); // 내 기록 보기
  }

  void _goToHowTo(BuildContext context) {
    Navigator.pushNamed(context, '/howto'); // ✅ 앱 사용 방법 페이지로 이동
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Voice Training',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(
                Icons.person_outline,
                color: Colors.white70,
              ),
              onPressed: () {
                // ✅ 사람 아이콘 클릭 시 마이페이지로 이동
                Navigator.pushNamed(context, '/mypage');
              },
            ),
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF060311),
              Color(0xFF120C2D),
              Color(0xFF060311),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // 👋 인사 & 타이틀
                const Text(
                  '환영합니다 👋',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '오늘도 목을 풀어볼까요?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: 80,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.purpleAccent,
                        Colors.cyanAccent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),
                const Text(
                  '메뉴 선택',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),

                // 🔥 메뉴 카드들
                _HomeMenuCard(
                  icon: Icons.search,
                  title: '노래 검색하기',
                  description: '한로로 - 사랑하게 될 거야부터 시작해봐요',
                  onTap: () => _goToSearch(context),
                  gradientColors: const [
                    Color(0xFF7B61FF),
                    Color(0xFF4A37A8),
                  ],
                ),
                const SizedBox(height: 16),
                _HomeMenuCard(
                  icon: Icons.history,
                  title: '내 기록 보기',
                  description: '지금까지 불렀던 곡과 점수를 한 번에 확인해요',
                  onTap: () => _goToHistory(context),
                  gradientColors: const [
                    Color(0xFF00C6FF),
                    Color(0xFF0072FF),
                  ],
                ),
                const SizedBox(height: 16),
                _HomeMenuCard(
                  icon: Icons.help_outline,
                  title: '앱 사용 방법',
                  description: '녹음 올리고 점수 확인하는 방법을 알려드려요',
                  onTap: () => _goToHowTo(context),
                  gradientColors: const [
                    Color(0xFFFF6FD8),
                    Color(0xFFFF8C42),
                  ],
                ),

                const Spacer(),

                // 작은 푸터 느낌
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '오늘도 좋은 목소리로 ✨',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      shadows: [
                        Shadow(
                          color: Colors.purpleAccent.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 💡 네온 카드 위젯
class _HomeMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final List<Color> gradientColors;

  const _HomeMenuCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withOpacity(0.04),
          border: Border.all(
            width: 1,
            color: gradientColors.first.withOpacity(0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // 아이콘 동그라미
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.circle, // placeholder, 아래서 바꿔줌
                  color: Colors.transparent,
                ),
              ),
            ),

            // 실제 아이콘을 위에 겹쳐서 배치
            PositionedIcon(icon: icon),

            const SizedBox(width: 16),

            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}

/// 아이콘을 네온 동그라미 가운데에 겹치게 올리기 위한 위젯
class PositionedIcon extends StatelessWidget {
  final IconData icon;

  const PositionedIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Transform.translate(
        offset: const Offset(-44, 0), // 왼쪽 동그라미 중앙으로 이동
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
