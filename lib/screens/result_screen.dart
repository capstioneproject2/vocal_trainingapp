import 'dart:math' as math;
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  String getComment(double score) {
    if (score >= 95) return "거의 원곡자 수준이에요 🔥";
    if (score >= 85) return "아주 잘했어요! 조금만 더 다듬으면 완벽해요 ✨";
    if (score >= 70) return "좋아요! 더 연습하면 실력이 확 올라갈 거예요 💪";
    return "아직 부족해요! 조금 더 연습해볼까요? 🎤";
  }

  Widget _buildError(String msg) {
    return Scaffold(
      appBar: AppBar(title: const Text("결과 보기")),
      body: Center(
        child: Text(
          msg,
          style: const TextStyle(color: Colors.red, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // JSON에서 숫자 배열 파싱
  List<double> _toDoubleList(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map((e) => e == null ? null : (e as num).toDouble())
        .whereType<double>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final argsRaw = ModalRoute.of(context)!.settings.arguments;
    if (argsRaw == null || argsRaw is! Map) {
      return _buildError("결과 데이터가 전달되지 않았어요. (args null)");
    }
    final Map args = argsRaw as Map;

    // ✅ 새 구조: status/meta/scores/graph_data/lyrics
    final String status = (args['status'] ?? '').toString();
    if (status != 'success') {
      return _buildError("분석이 실패했어요. status=$status");
    }

    final Map? meta = args['meta'] as Map?;
    final Map? scores = args['scores'] as Map?;
    final Map? graphData = args['graph_data'] as Map?;
    final List<dynamic> lyricsRaw = (args['lyrics'] ?? []) as List<dynamic>;

    if (meta == null || scores == null || graphData == null) {
      return _buildError("meta/scores/graph_data가 없어요.");
    }

    final double hopLength = (meta['hop_length'] as num?)?.toDouble() ?? 0.01;
    final int totalFrames = (meta['total_frames'] as num?)?.round() ?? 0;
    final double totalDurationSec =
        (meta['total_duration_sec'] as num?)?.toDouble() ?? 0.0;

    final double pitchError =
        (scores['pitch_error'] as num?)?.toDouble() ?? 0.0;
    final double rhythmErrorSec =
        (scores['rhythm_error_sec'] as num?)?.toDouble() ?? 0.0;
    final double finalScore =
        (scores['final_score'] as num?)?.toDouble() ?? 0.0;

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

    // 곡 정보 (너 프로젝트 기존 args에서 쓰던 singer/title 없으면 대충 표시)
    final String title = (args['title'] ?? '결과') as String;
    final String singer = (args['singer'] ?? '') as String;

    if (refPitch.isEmpty || recPitch.isEmpty) {
      return _buildError("그래프 데이터가 비어 있어요. (ref/rec)");
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("결과 보기"),
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

                // 하단 버튼
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shadowColor: Colors.deepPurpleAccent.withOpacity(0.5),
                          elevation: 8,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("다시 연습하기",
                            style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shadowColor: Colors.cyanAccent.withOpacity(0.5),
                          elevation: 8,
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/search'),
                        child: const Text("다른 곡 선택",
                            style: TextStyle(fontSize: 16, color: Colors.black)),
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

/// ✅ 가사 포인트(그래프 인덱스 기반)
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

/// ✅ 그래프 + 가사(겹침 방지 여러 줄)
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

    // 가로 스크롤: 프레임 수 기반으로 넓게
    return LayoutBuilder(
      builder: (context, constraints) {
        // 프레임당 px (15~25 추천)
        const double pxPerFrame = 2.5; // 1500 frames면 3750px 정도
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
    // 배경
    final bgPaint = Paint()
      ..color = const Color(0x11FFFFFF)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      bgPaint,
    );

    // 위쪽에 가사 레인 공간 확보
    const double topPad = 10;
    const double leftPad = 10;
    const double rightPad = 10;
    const double bottomPad = 10;

    const double lyricLaneHeight = 18; // 한 줄 높이
    const int maxLanes = 4;            // 최대 4줄까지 내려줌
    const double lyricAreaHeight = lyricLaneHeight * maxLanes + 8;

    // 그래프 영역(가사 아래부터)
    final Rect graphRect = Rect.fromLTWH(
      leftPad,
      topPad + lyricAreaHeight,
      size.width - leftPad - rightPad,
      size.height - (topPad + lyricAreaHeight) - bottomPad,
    );

    if (graphRect.height <= 10 || graphRect.width <= 10) return;

    // f0 범위
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

    // x: index 기반
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

    // 축/그리드
    final axisPaint = Paint()
      ..color = const Color(0x44FFFFFF)
      ..strokeWidth = 1;

    canvas.drawRect(graphRect, axisPaint..style = PaintingStyle.stroke);

    const int hLines = 4;
    for (int i = 1; i < hLines; i++) {
      final dy = graphRect.top + graphRect.height * (i / hLines);
      canvas.drawLine(Offset(graphRect.left, dy), Offset(graphRect.right, dy), axisPaint);
    }

    // ref 라인
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

    // rec 라인
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

    // ✅ 가사 표시(겹침 방지: lane 배치)
    // lane별로 "마지막으로 사용한 x 끝"을 기록해두고,
    // 다음 가사가 그 x와 겹치면 아래 lane으로 내림.
    final List<double> laneLastRight = List<double>.filled(maxLanes, -1e9);

    final TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    final lyricStyle = TextStyle(
      color: Colors.white.withOpacity(0.75),
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    // 보기 좋게 index 순으로 정렬
    final sortedLyrics = [...lyrics]..sort((a, b) => a.graphIndex.compareTo(b.graphIndex));

    for (final l in sortedLyrics) {
      final int idx = l.graphIndex.clamp(0, maxIndex);
      final double x = xFromIndex(idx);

      tp.text = TextSpan(text: l.text, style: lyricStyle);
      tp.layout(maxWidth: 200);

      // 가사 박스 폭
      final double w = tp.width;
      final double half = w / 2;

      // 배치할 left/right (그래프 영역 기준으로 clamp)
      double left = x - half;
      left = left.clamp(graphRect.left, graphRect.right - w);
      final double right = left + w;

      // lane 선택
      int lane = 0;
      const double gap = 8; // 가사 사이 최소 간격
      while (lane < maxLanes && left <= laneLastRight[lane] + gap) {
        lane++;
      }
      if (lane >= maxLanes) {
        // lane이 꽉 차면 마지막 줄에라도 넣기(겹칠 수는 있지만 최소화)
        lane = maxLanes - 1;
      }

      // y 위치 (가사 영역)
      final double y = topPad + 4 + lane * lyricLaneHeight;

      // 얇은 가이드 라인(가사 위치 표시)
      final guidePaint = Paint()
        ..color = Colors.white.withOpacity(0.12)
        ..strokeWidth = 1;

      canvas.drawLine(
        Offset(x, graphRect.top),
        Offset(x, graphRect.top - 6),
        guidePaint,
      );

      // 가사 배경(가독성)
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
