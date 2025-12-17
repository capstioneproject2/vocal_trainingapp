import 'package:flutter/material.dart';

class HowToScreen extends StatelessWidget {
  const HowToScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("앱 사용 방법"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF05030A),
              Color(0xFF15112F),
              Color(0xFF05030A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 타이틀
                Text(
                  "Voice Training\n이렇게 사용해요 🎤",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [
                          Colors.cyanAccent,
                          Colors.purpleAccent,
                        ],
                      ).createShader(
                        const Rect.fromLTWH(0, 0, 250, 60),
                      ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "노래를 녹음해서 진짜 노래의 음정과 비교하고,\n"
                      "그래프로 확인하면서 점수까지 볼 수 있는 앱이에요.",
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 28),

                // Step 1
                _StepCard(
                  step: "STEP 1",
                  title: "노래 선택하기",
                  icon: Icons.search,
                  gradientColors: const [
                    Color(0xFF7B61FF),
                    Color(0xFFB37CFF),
                  ],
                  description:
                  "홈 화면에서 [노래 검색하기]를 눌러\n‘사랑하게 될 거야 - 한로로’를 선택해요.\n"
                      "앞으로는 다른 곡들도 여기서 선택할 예정이에요.",
                ),

                const SizedBox(height: 18),

                // Step 2
                _StepCard(
                  step: "STEP 2",
                  title: "WAV 파일 업로드",
                  icon: Icons.cloud_upload_outlined,
                  gradientColors: const [
                    Color(0xFF00D4FF),
                    Color(0xFF0072FF),
                  ],
                  description:
                  "[스코어 보기]를 누른 뒤,\n녹음해 둔 노래 WAV 파일을 첨부해요.\n"
                      "mp3 / wav 파일을 지원하고, 업로드 후 분석이 시작돼요.",
                ),

                const SizedBox(height: 18),

                // Step 3
                _StepCard(
                  step: "STEP 3",
                  title: "음정 그래프 & 점수 확인",
                  icon: Icons.show_chart,
                  gradientColors: const [
                    Color(0xFFFF6FD8),
                    Color(0xFFFF8C42),
                  ],
                  description:
                  "백엔드 서버에서 Python으로\n"
                      "진짜 노래의 음정과 내가 부른 음정을 비교해요.\n"
                      "• 피치(음정) 그래프\n• 음정 정확도 / 리듬 안정도\n• 총 점수\n을 한 눈에 볼 수 있어요.",
                ),

                const SizedBox(height: 28),

                // 연습모드 vs 스코어 모드 설명
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withOpacity(0.04),
                    border: Border.all(
                      color: Colors.cyanAccent.withOpacity(0.6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "연습 모드 vs 스코어 보기",
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "• 스코어 보기\n"
                            "  → 내가 부른 노래를 WAV로 올리면,\n"
                            "     진짜 노래의 음정과 비교해서 그래프 & 점수를 보여줘요.\n\n"
                            "• 연습 모드\n"
                            "  → 점수 없이 자유롭게 녹음하고,\n"
                            "     내 목소리를 들어보면서 연습만 하는 모드예요.",
                        style: TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "이제 직접 불러볼까요? ✨",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                      shadows: [
                        Shadow(
                          color: Colors.purpleAccent.withOpacity(0.6),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String step;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;

  const _StepCard({
    super.key,
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(
          color: gradientColors.first.withOpacity(0.7),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          // 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
