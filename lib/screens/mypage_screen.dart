import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';
import '../screens/HistoryDetailScreen.dart'; // 🔥 추가

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = UserSession.userId ?? '게스트';
      final data = await ApiService.getUserHistory(userId);
      setState(() {
        _history = data;
      });
    } catch (e) {
      setState(() {
        _error = '기록을 불러오는 중 오류가 발생했습니다.';
      });
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = UserSession.userId ?? '게스트';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Page', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF05030A),
              Color(0xFF15112C),
              Color(0xFF05030A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 유저 정보
                Row(
                  children: [
                    const Icon(Icons.person_pin,
                        color: Colors.purpleAccent, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'ID: $userId',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Text(
                  '🎵 나의 노래 기록',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                Expanded(
                  child: _isLoading
                      ? const Center(
                    child: CircularProgressIndicator(
                        color: Colors.purpleAccent),
                  )
                      : _error != null
                      ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  )
                      : _history.isEmpty
                      ? const Center(
                    child: Text(
                      '아직 불러본 곡이 없어요.\n첫 곡을 불러볼까요? 🎤',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white54, height: 1.5),
                    ),
                  )
                      : ListView.separated(
                    itemCount: _history.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = _history[index];

                      final String recordId = item['_id'] as String? ?? '';

                      final title =
                          item['songtitle'] as String? ?? '제목 없음';
                      final singer =
                          item['singer'] as String? ?? '알 수 없음';
                      final scoreNum = item['score'] as num? ?? 0;
                      final int score = scoreNum.toInt();

                      String date =
                          item['date'] as String? ?? '';
                      if (date.length > 10) {
                        date = date.substring(0, 10);
                      }
                      print('아이디: $recordId');

                      return _HistoryCard(
                        title: title,
                        artist: singer,
                        score: score,
                        date: date,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HistoryDetailScreen(

                                    recordId: recordId,

                                    basicInfo: {
                                      'userId': userId,
                                      'songtitle': title,
                                      'singer': singer,
                                      'score': score,
                                      'date': date,
                                    },
                                  ),
                            ),
                          );
                        },
                      );
                    },
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

// ---------------- 카드 ----------------

class _HistoryCard extends StatelessWidget {
  final String title;
  final String artist;
  final int score;
  final String date;
  final VoidCallback onTap; // 🔥 추가

  const _HistoryCard({
    required this.title,
    required this.artist,
    required this.score,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color glowColor = score >= 90
        ? Colors.cyanAccent
        : (score >= 80 ? Colors.purpleAccent : Colors.orangeAccent);

    return InkWell(
      onTap: onTap, // 🔥 연결
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF3A1F66),
              Color(0xFF6D2C8F),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.3),
                border: Border.all(color: glowColor, width: 2),
              ),
              child: Center(
                child: Text(
                  '$score',
                  style: TextStyle(
                    color: glowColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
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
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.mic,
                          size: 12, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        artist,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.calendar_today,
                          size: 12, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
