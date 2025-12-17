import 'package:flutter/material.dart';

class SongSearchScreen extends StatefulWidget {
  const SongSearchScreen({super.key});

  @override
  State<SongSearchScreen> createState() => _SongSearchScreenState();
}

class _SongSearchScreenState extends State<SongSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final String _songTitle = '사랑하게 될 거야';
  final String _songArtist = '한로로';

  String _displayTitle = '사랑하게 될 거야 - 한로로';
  String? _errorText;

  void _onSearch() {
    final query = _searchController.text.trim();

    if (query.isEmpty ||
        query.contains('사랑') ||
        query.contains('한로로') ||
        query.contains('사랑하게 될 거야')) {
      setState(() {
        _displayTitle = '사랑하게 될 거야 - 한로로';
        _errorText = null;
      });
    } else {
      setState(() {
        _displayTitle = '';
        _errorText = '검색 결과가 없습니다.';
      });
    }
  }

  /// ✅ 여기: 곡 눌렀을 때 뜨는 바텀시트 (크게 + 예쁘게)
  void _showActionSheet() {
    if (_displayTitle.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // 화면 높이 많이 쓰게
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.42, // 전체 화면의 42% 정도 차지
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF070716).withOpacity(0.98),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.7),
                  blurRadius: 20,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 상단 바
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),

                // 선택된 곡 타이틀
                Text(
                  '$_songTitle - $_songArtist',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '원하는 모드를 선택해 주세요',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),

                // 🔥 큰 네온 버튼 2개 (연습 / 스코어)
                Row(
                  children: [
                    Expanded(
                      child: _BottomActionButton(
                        icon: Icons.mic,
                        label: '연습하기',
                        gradientColors: const [
                          Color(0xFF00E5FF),
                          Color(0xFF00B8D4),
                        ],
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/practice');
                        },
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _BottomActionButton(
                        icon: Icons.bar_chart,
                        label: '스코어 보기',
                        gradientColors: const [
                          Color(0xFFFF6FD8),
                          Color(0xFFFF8C42),
                        ],
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            '/training',
                            arguments: {
                              'singer': _songArtist,
                              'title': _songTitle,
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                const Text(
                  '연습 모드는 자유롭게 녹음하고 들어볼 수 있어요.',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("노래 검색하기"),
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '부르고 싶은 노래를 검색해보세요',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),

                // 🔍 검색바 + 버튼
                Row(
                  children: [
                    const Icon(Icons.search,
                        color: Colors.cyanAccent, size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.cyanAccent,
                        decoration: InputDecoration(
                          hintText: '사랑하게 될 거야 - 한로로',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide:
                            const BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide:
                            const BorderSide(color: Colors.cyanAccent),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _onSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 18,
                        ),
                      ),
                      child: const Text("검색"),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                if (_errorText != null)
                  Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),

                // 🎵 검색 결과 카드
                if (_displayTitle.isNotEmpty)
                  InkWell(
                    onTap: _showActionSheet,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.white.withOpacity(0.04),
                        border: Border.all(
                          color: Colors.purpleAccent.withOpacity(0.7),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purpleAccent.withOpacity(0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF7B61FF),
                                  Color(0xFFB37CFF),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(Icons.music_note,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _displayTitle,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: Colors.white70),
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

/// 🔹 바텀시트 안에서 쓰는 네온 버튼 위젯
class _BottomActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _BottomActionButton({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.55),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




