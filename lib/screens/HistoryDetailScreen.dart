import 'dart:math' as math;
import 'package:flutter/material.dart';
// ApiService가 있는 경로를 import 해주세요.
import '../services/api_service.dart';

class HistoryDetailScreen extends StatefulWidget {
  final String recordId;
  final Map<String, dynamic> basicInfo;

  // MyPageScreen에서 보낸 basicInfo: {userId, songTitle, singer, score, date}
  const HistoryDetailScreen({
    super.key,
    required this.recordId,
    required this.basicInfo,
  });

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _detailData;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final userId = widget.basicInfo['userId'];
      final title = widget.basicInfo['songTitle'];
      final date = widget.basicInfo['date'];

      // 서버에서 상세 데이터 가져오기 (그래프, 가사 등)
      final data = await ApiService.getHistoryDetail(widget.recordId);

      if (mounted) {
        setState(() {
          _detailData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // ResultScreen과 동일한 로직: JSON 파싱
  List<double> _toDoubleList(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map((e) => e == null ? null : (e as num).toDouble())
        .whereType<double>()
        .toList();
  }

  String getComment(double score) {
    if (score >= 95) return "거의 원곡자 수준이에요 🔥";
    if (score >= 85) return "아주 잘했어요! 조금만 더 다듬으면 완벽해요 ✨";
    if (score >= 70) return "좋아요! 더 연습하면 실력이 확 올라갈 거예요 💪";
    return "아직 부족해요! 조금 더 연습해볼까요? 🎤";
  }

  Widget _buildError(String msg) {
    return Scaffold(
      appBar: AppBar(title: const Text("상세 결과 보기")),
      body: Center(
        child: Text(
          msg,
          style: const TextStyle(color: Colors.red, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. 로딩 중
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF08010F), // 배경색 맞춤
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 2. 에러 발생
    if (_errorMessage != null) {
      return _buildError("데이터를 불러오지 못했어요.\n$_errorMessage");
    }

    // 3. 데이터 없음
    if (_detailData == null) {
      return _buildError("상세 데이터가 없습니다.");
    }

    // ResultScreen 로직 그대로 적용
    final Map args = _detailData!;

    // 👇 [추가] 이 줄을 추가해서 콘솔 창을 확인해보세요!
    print("🔥 [디버깅] 서버 데이터 전체: $args");
    print("    - meta 존재여부: ${args.containsKey('meta')}");
    print("    - scores 존재여부: ${args.containsKey('scores')}");
    print("    - graph_data 존재여부: ${args.containsKey('graph_data')}");

    final Map? meta = args['meta'] as Map?;
    final Map? scores = args['scores'] as Map?;
    final Map? graphData = args['graph_data'] as Map?;
    final List<dynamic> lyricsRaw = (args['lyrics'] ?? []) as List<dynamic>;

    if (meta == null || scores == null || graphData == null) {
      // 일부 데이터가 없을 경우 basicInfo의 기본값으로 최대한 표시 시도 (혹은 에러처리)
      return _buildError("서버 데이터 형식이 올바르지 않습니다. (meta/scores/graph missing)");
    }

    final double hopLength = (meta['hop_length'] as num?)?.toDouble() ?? 0.01;
    final int totalFrames = (meta['total_frames'] as num?)?.round() ?? 0;
    final double totalDurationSec =
        (meta['total_duration_sec'] as num?)?.toDouble() ?? 0.0;

    final double pitchError =
        (scores['pitch_error'] as num?)?.toDouble() ?? 0.0;
    final double rhythmErrorSec =
        (scores['rhythm_error_sec'] as num?)?.toDouble() ?? 0.0;

    // finalScore는 서버 데이터 우선, 없으면 basicInfo의 점수 사용
    final double finalScore = (scores['final_score'] as num?)?.toDouble() ??
        (widget.basicInfo['score'] as num?)?.toDouble() ?? 0.0;

    final List<double> refPitch = _toDoubleList(graphData['ref_pitch']);
    final List<double> recPitch = _toDoubleList(graphData['rec_pitch']);

    final List<LyricPoint> lyrics = lyricsRaw
        .whereType<Map>()
        .map((m) {
      return LyricPoint(
        text: (m['text'] ?? '').toString(),
        timeSec: (m['time_sec'] as num?)?.toDouble() ?? 0.0,
        graphIndex: (m['graph_index'] as num?)?.round() ?? 0,
      );
    })
        .where((p) => p.text.trim().isNotEmpty)
        .toList();

    // 제목/가수는 basicInfo 사용 (서버 응답에 없을 수도 있으므로)
    final String title = widget.basicInfo['songTitle'] ?? (args['title'] ?? '결과');
    final String singer = widget.basicInfo['singer'] ?? (args['singer'] ?? '');

    if (refPitch.isEmpty || recPitch.isEmpty) {
      return _buildError("그래프 데이터가 비어 있어요. (ref/rec)");
    }

    // ============================================================
    // 여기서부터 ResultScreen UI 코드 100% 복사
    // ============================================================
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("상세 결과 보기"), // 타이틀만 변경
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF08010F), Color(0xFF0F0A2C), Color(0xFF07031A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.purpleAccent, blurRadius: 12),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          singer.isEmpty
                              ? "총 길이: ${totalDurationSec.toStringAsFixed(1)}s · hop=${hopLength.toStringAsFixed(2)}s"
                              : "$singer · ${totalDurationSec.toStringAsFixed(1)}s",
                          style: const TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                        const SizedBox(height: 22),

                        // 총점 카드
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2A00FF), Color(0xFF9900FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurpleAccent.withOpacity(0.6),
                                  blurRadius: 25,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text("총 점수",
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 14)),
                                const SizedBox(height: 6),
                                Text(
                                  "${finalScore.toStringAsFixed(1)}점",
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(color: Colors.white, blurRadius: 18),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  getComment(finalScore),
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // 간단 지표 카드 2개
                        Row(
                          children: [
                            Expanded(
                              child: _MiniMetricCard(
                                title: "Pitch error",
                                value: "${pitchError.toStringAsFixed(1)} Hz",
                                borderColor: Colors.blueAccent,
                                glowColor: Colors.blueAccent,
                                valueColor: Colors.blueAccent.shade100,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _MiniMetricCard(
                                title: "Rhythm error",
                                value: "${rhythmErrorSec.toStringAsFixed(2)} s",
                                borderColor: Colors.pinkAccent,
                                glowColor: Colors.pinkAccent,
                                valueColor: Colors.pinkAccent,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // 그래프 카드 (가사 포함)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.cyanAccent.withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(0.25),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                            ],
                            color: Colors.white.withOpacity(0.02),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "원곡 vs 녹음 (가사 표시)",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                SizedBox(
                                  height: 260,
                                  child: PitchGraphWithLyrics(
                                    refPitch: refPitch,
                                    recPitch: recPitch,
                                    lyrics: lyrics,
                                    totalFrames: totalFrames,
                                    totalDurationSec: totalDurationSec,
                                  ),
                                ),

                                const SizedBox(height: 8),
                                Text(
                                  "※ 가사는 graph_index 기준으로 위치하며, 겹치면 자동으로 여러 줄로 내려갑니다.",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.45),
                                    fontSize: 11,
                                  ),
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

                // 하단 버튼 (이전 화면으로 돌아가기)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 8,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("목록으로 돌아가기",
                            style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------
// 아래는 ResultScreen에 있던 헬퍼 클래스들을 그대로 가져왔습니다.
// (동일한 파일에 복사하거나, ResultScreen이 있는 파일을 import해서 쓰셔도 됩니다)
// -----------------------------------------------------------

class _MiniMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color borderColor;
  final Color glowColor;
  final Color valueColor;

  const _MiniMetricCard({
    required this.title,
    required this.value,
    required this.borderColor,
    required this.glowColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withOpacity(0.7), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.35),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
        color: Colors.white.withOpacity(0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class LyricPoint {
  final String text;
  final double timeSec;
  final int graphIndex;

  LyricPoint({
    required this.text,
    required this.timeSec,
    required this.graphIndex,
  });
}

class PitchGraphWithLyrics extends StatelessWidget {
  final List<double> refPitch;
  final List<double> recPitch;
  final List<LyricPoint> lyrics;
  final int totalFrames;
  final double totalDurationSec;

  const PitchGraphWithLyrics({
    super.key,
    required this.refPitch,
    required this.recPitch,
    required this.lyrics,
    required this.totalFrames,
    required this.totalDurationSec,
  });

  @override
  Widget build(BuildContext context) {
    if (refPitch.isEmpty || recPitch.isEmpty) {
      return const Center(
        child: Text("그래프 데이터가 부족해요.",
            style: TextStyle(color: Colors.white54, fontSize: 12)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const double pxPerFrame = 2.5;
        final double minWidth = constraints.maxWidth;
        final double widthByFrames = refPitch.length * pxPerFrame;
        final double canvasWidth =
        widthByFrames < minWidth ? minWidth : widthByFrames;

        return Scrollbar(
          thumbVisibility: true,
          notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: canvasWidth,
              child: CustomPaint(
                painter: _PitchGraphPainter(
                  refPitch: refPitch,
                  recPitch: recPitch,
                  lyrics: lyrics,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PitchGraphPainter extends CustomPainter {
  final List<double> refPitch;
  final List<double> recPitch;
  final List<LyricPoint> lyrics;

  _PitchGraphPainter({
    required this.refPitch,
    required this.recPitch,
    required this.lyrics,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = const Color(0x11FFFFFF)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      bgPaint,
    );

    const double topPad = 10;
    const double leftPad = 10;
    const double rightPad = 10;
    const double bottomPad = 10;

    const double lyricLaneHeight = 18;
    const int maxLanes = 4;
    const double lyricAreaHeight = lyricLaneHeight * maxLanes + 8;

    final Rect graphRect = Rect.fromLTWH(
      leftPad,
      topPad + lyricAreaHeight,
      size.width - leftPad - rightPad,
      size.height - (topPad + lyricAreaHeight) - bottomPad,
    );

    if (graphRect.height <= 10 || graphRect.width <= 10) return;

    double minF0 = 999999;
    double maxF0 = 0;

    void scan(List<double> arr) {
      for (final v in arr) {
        if (v > 0) {
          minF0 = math.min(minF0, v);
          maxF0 = math.max(maxF0, v);
        }
      }
    }

    scan(refPitch);
    scan(recPitch);

    if (minF0 == 999999 || maxF0 == 0) {
      minF0 = 80;
      maxF0 = 400;
    }

    final double paddingF0 = (maxF0 - minF0) * 0.1;
    minF0 -= paddingF0;
    maxF0 += paddingF0;

    final int maxIndex = math.max(refPitch.length, recPitch.length) - 1;
    double xFromIndex(int idx) {
      if (maxIndex <= 0) return graphRect.left;
      final r = (idx / maxIndex).clamp(0.0, 1.0);
      return graphRect.left + r * graphRect.width;
    }

    double yFromF0(double f0) {
      if (maxF0 <= minF0) return graphRect.center.dy;
      final r = ((f0 - minF0) / (maxF0 - minF0)).clamp(0.0, 1.0);
      return graphRect.bottom - r * graphRect.height;
    }

    final axisPaint = Paint()
      ..color = const Color(0x44FFFFFF)
      ..strokeWidth = 1;

    canvas.drawRect(graphRect, axisPaint..style = PaintingStyle.stroke);

    const int hLines = 4;
    for (int i = 1; i < hLines; i++) {
      final dy = graphRect.top + graphRect.height * (i / hLines);
      canvas.drawLine(Offset(graphRect.left, dy), Offset(graphRect.right, dy), axisPaint);
    }

    final refPaint = Paint()
      ..color = const Color(0xFF6EC6FF)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final refPath = Path();
    bool started = false;
    for (int i = 0; i < refPitch.length; i++) {
      final f0 = refPitch[i];
      if (f0 <= 0) {
        started = false;
        continue;
      }
      final x = xFromIndex(i);
      final y = yFromF0(f0);
      if (!started) {
        refPath.moveTo(x, y);
        started = true;
      } else {
        refPath.lineTo(x, y);
      }
    }
    canvas.drawPath(refPath, refPaint);

    final recPaint = Paint()
      ..color = const Color(0xFFFF80AB)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final recPath = Path();
    started = false;
    for (int i = 0; i < recPitch.length; i++) {
      final f0 = recPitch[i];
      if (f0 <= 0) {
        started = false;
        continue;
      }
      final x = xFromIndex(i);
      final y = yFromF0(f0);
      if (!started) {
        recPath.moveTo(x, y);
        started = true;
      } else {
        recPath.lineTo(x, y);
      }
    }
    canvas.drawPath(recPath, recPaint);

    final List<double> laneLastRight = List<double>.filled(maxLanes, -1e9);

    final TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    final lyricStyle = TextStyle(
      color: Colors.white.withOpacity(0.75),
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    final sortedLyrics = [...lyrics]..sort((a, b) => a.graphIndex.compareTo(b.graphIndex));

    for (final l in sortedLyrics) {
      final int idx = l.graphIndex.clamp(0, maxIndex);
      final double x = xFromIndex(idx);

      tp.text = TextSpan(text: l.text, style: lyricStyle);
      tp.layout(maxWidth: 200);

      final double w = tp.width;
      final double half = w / 2;

      double left = x - half;
      left = left.clamp(graphRect.left, graphRect.right - w);
      final double right = left + w;

      int lane = 0;
      const double gap = 8;
      while (lane < maxLanes && left <= laneLastRight[lane] + gap) {
        lane++;
      }
      if (lane >= maxLanes) {
        lane = maxLanes - 1;
      }

      final double y = topPad + 4 + lane * lyricLaneHeight;

      final guidePaint = Paint()
        ..color = Colors.white.withOpacity(0.12)
        ..strokeWidth = 1;

      canvas.drawLine(
        Offset(x, graphRect.top),
        Offset(x, graphRect.top - 6),
        guidePaint,
      );

      final RRect pill = RRect.fromRectAndRadius(
        Rect.fromLTWH(left - 6, y - 2, w + 12, lyricLaneHeight),
        const Radius.circular(10),
      );

      final pillPaint = Paint()..color = Colors.black.withOpacity(0.25);
      canvas.drawRRect(pill, pillPaint);

      tp.paint(canvas, Offset(left, y));

      laneLastRight[lane] = right;
    }
  }

  @override
  bool shouldRepaint(covariant _PitchGraphPainter oldDelegate) {
    return refPitch != oldDelegate.refPitch ||
        recPitch != oldDelegate.recPitch ||
        lyrics != oldDelegate.lyrics;
  }
}