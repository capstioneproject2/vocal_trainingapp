import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  PlatformFile? _selectedFile;
  bool _isLoading = false;
  String? _error;

  String? _singer;
  String? _title;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _singer = args['singer'] as String?;
      _title = args['title'] as String?;
    }
    _initialized = true;
  }

  Future<void> _pickFile() async {
    setState(() => _error = null);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav'],
      withData: true, // 웹에서 bytes 필요
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.single);
    }
  }

  Future<void> _upload() async {
    if (_singer == null || _title == null) {
      setState(() => _error = '노래 정보가 없습니다. 노래를 다시 선택해 주세요.');
      return;
    }

    if (_selectedFile == null) {
      setState(() => _error = '먼저 mp3 또는 wav 파일을 선택해 주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // ✅ 로그인 붙이면 여기만 UserSession.userId로 바꿔
      final String userId = 'test';

      // ✅ 1) 업로드 (positional: file 먼저, named: singer/title/userId)
      final res = await ApiService.uploadSong(
        _selectedFile!,
        singer: _singer!,
        title: _title!,
        userId: userId,
      );

      if (!mounted) return;

      // ✅ 2) 백엔드 응답 구조에 따라 analysis 추출
      // - 어떤 서버는 { ok:true, data:{...} } 로 주고
      // - 어떤 서버는 { status:'success', meta:..., ... } 로 바로 줌
      final dynamic analysis = (res is Map && res['data'] != null) ? res['data'] : res;

      if (analysis is! Map) {
        throw '분석 결과 형식이 이상해요: $analysis';
      }

      // ✅ 3) ResultScreen(너가 올린 새 코드)이 기대하는 최상위 키로 "풀어서" 전달
      Navigator.pushNamed(
        context,
        '/result',
        arguments: {
          // 화면 표시용(옵션)
          'singer': _singer!,
          'title': _title!,

          // ResultScreen이 쓰는 핵심 필드들
          'status': analysis['status'],
          'meta': analysis['meta'],
          'scores': analysis['scores'],
          'graph_data': analysis['graph_data'],
          'lyrics': analysis['lyrics'],

          // 에러 메시지 있을 때 대비
          'message': analysis['message'],
        },
      );
    } catch (e) {
      setState(() => _error = '업로드 중 오류 발생: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final songInfo = (_singer != null && _title != null)
        ? '$_title - $_singer'
        : '선택된 노래 없음';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Score 보기'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF05030A),
              Color(0xFF17132C),
              Color(0xFF05030A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 선택된 노래 카드
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7B61FF),
                        Color(0xFF4A37A8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '선택한 노래',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        songInfo,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  '직접 부른 노래 파일을 첨부해 주세요\n* mp3, wav 파일 지원',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                // 파일 선택 박스
                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white.withOpacity(0.04),
                      border: Border.all(
                        color: Colors.cyanAccent.withOpacity(0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          color: Colors.cyanAccent,
                          size: 30,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _selectedFile != null
                                ? _selectedFile!.name
                                : '노래 파일 선택하기',
                            style: TextStyle(
                              color: _selectedFile != null
                                  ? Colors.white
                                  : Colors.white60,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _upload,
                    child: _isLoading
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text(
                      'Score 분석 시작',
                      style: TextStyle(fontSize: 16),
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
