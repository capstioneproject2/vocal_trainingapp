import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool _hasRecorded = false;
  String? _filePath;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // 🔴 녹음 시작
  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('마이크 권한이 필요합니다.')),
      );
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/practice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );

    setState(() {
      _isRecording = true;
      _filePath = path;
      _hasRecorded = false;
    });

    _pulseController.repeat(reverse: true);
  }

  // ⏹ 녹음 종료
  Future<void> _stopRecording() async {
    final path = await _recorder.stop();

    setState(() {
      _isRecording = false;
      _filePath = path ?? _filePath;
      _hasRecorded = _filePath != null;
    });

    _pulseController.stop();
    _pulseController.reset();

    debugPrint('녹음 저장됨: $_filePath');
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  // ▶ 마지막 녹음 재생
  Future<void> _playLastRecording() async {
    if (!_hasRecorded || _filePath == null) return;
    await _player.stop();
    await _player.play(DeviceFileSource(_filePath!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "연습하기",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF05030A),
              Color(0xFF15112C),
              Color(0xFF05030A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),

              // 🎵 네온 타이틀
              Text(
                "연습 모드",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [
                        Colors.cyanAccent,
                        Colors.purpleAccent,
                      ],
                    ).createShader(
                      const Rect.fromLTWH(0, 0, 220, 70),
                    ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "마이크를 켜고 자유롭게 불러보고,\n녹음해서 다시 들어보세요!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 30),

              _buildNeonMicCard(),
              const SizedBox(height: 30),
              _buildTipsCard(),
              const Spacer(),
              _buildRecordButton(),
              const SizedBox(height: 18),
              _buildPlayButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ⭐ 네온 마이크 카드
  Widget _buildNeonMicCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.purpleAccent.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ScaleTransition(
            scale: Tween(begin: 1.0, end: 1.15).animate(
              CurvedAnimation(
                parent: _pulseController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Icon(
              Icons.mic,
              size: 60,
              color: _isRecording ? Colors.redAccent : Colors.cyanAccent,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isRecording ? "녹음 중..." : "마이크 대기 중",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          if (_hasRecorded)
            const Text(
              "마지막 녹음이 저장되어 있어요 🎧",
              style: TextStyle(
                color: Colors.white60,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }

  // ⭐ 연습 팁 카드
  Widget _buildTipsCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🎧 연습 조언",
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "• 높고 어려운 부분은 따로 잘라서 반복해서 불러보세요.\n"
                "• 자신의 음정을 체크하며 불러보면 더 효과적이에요!\n"
                "• 녹음 후 들어보면 빠르게 실력 향상 가능 ✨",
            style: TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ⭐ 중앙 네온 녹음 버튼
  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: _toggleRecording,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: _isRecording
                ? const [Colors.redAccent, Colors.orangeAccent]
                : const [Colors.cyanAccent, Colors.purpleAccent],
          ),
          boxShadow: [
            BoxShadow(
              color: _isRecording
                  ? Colors.redAccent.withOpacity(0.6)
                  : Colors.cyanAccent.withOpacity(0.6),
              blurRadius: 22,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Icon(
          _isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  // ⭐ 마지막 녹음 듣기 버튼
  Widget _buildPlayButton() {
    return Opacity(
      opacity: _hasRecorded ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: _hasRecorded ? _playLastRecording : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white24,
            ),
            color: Colors.white.withOpacity(0.06),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.play_arrow, color: Colors.white70, size: 20),
              SizedBox(width: 6),
              Text(
                "마지막 녹음 듣기",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
