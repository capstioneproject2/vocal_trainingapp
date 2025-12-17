// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = "http://10.50.110.96:3000";

  static const String loginUrl = "$baseUrl/login";
  static const String analyzeUrl = "$baseUrl/analyze";

  /// ===============================
  /// 1) 로그인
  /// ===============================
  static Future<void> sendUserId(String userId, String password) async {
    final uri = Uri.parse(loginUrl);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('로그인 실패: ${response.statusCode} ${response.body}');
    }
  }

  /// ===============================
  /// 2) 업로드 (파일 + meta JSON)
  /// ===============================
  static Future<Map<String, dynamic>> uploadSong(
      PlatformFile file, {
        required String singer,
        required String title,
        required String userId,
      }) async {
    final uri = Uri.parse(analyzeUrl);
    final request = http.MultipartRequest('POST', uri);

    // (A) 오디오 파일 파트
    if (file.bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'record',
          file.bytes!,
          filename: file.name,
          contentType: MediaType('audio', file.extension ?? 'wav'),
        ),
      );
    } else if (file.path != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'record',
          file.path!,
          contentType: MediaType('audio', file.extension ?? 'wav'),
        ),
      );
    } else {
      throw Exception('파일 데이터를 찾을 수 없습니다.');
    }

    // (B) meta JSON 파트
    final metaJson = jsonEncode({
      'title': title,
      'singer': singer,
      'userId': userId,
    });

    request.files.add(
      http.MultipartFile.fromString(
        'meta',
        metaJson,
        contentType: MediaType('application', 'json'),
      ),
    );

    // (C) 전송
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = utf8.decode(response.bodyBytes);

    if (streamed.statusCode != 200) {
      throw Exception('업로드 실패: ${streamed.statusCode} $body');
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;

    throw Exception('예상치 못한 응답 형식: $decoded');
  }

  /// ===============================
  /// 3) 히스토리 목록
  /// ===============================
  static Future<List<Map<String, dynamic>>> getUserHistory(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/history?userId=$userId');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        if (jsonResponse['ok'] == true) {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message']);
        }
      } else {
        throw Exception("서버 연결 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("히스토리 에러: $e");
      throw Exception("기록을 불러오지 못했어요.");
    }
  }

  /// ===============================
  /// 4) 상세 정보 (그래프, 점수 등)
  /// ===============================
  // lib/services/api_service.dart

// ... (위쪽 코드는 그대로) ...

  static Future<Map<String, dynamic>> getHistoryDetail(String id) async {
    final uri = Uri.parse('$baseUrl/history/detail');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id' : id,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      // [수정된 부분] 2중 포장 벗기기 로직
      if (decoded is Map<String, dynamic> && decoded.containsKey('resultData')) {

        // 1차: 서버 응답의 'resultData'를 꺼냄 (DB Document 전체)
        var recordDocument = decoded['resultData'];

        // 2차: DB Document 안에 또 'resultData' 필드가 있는지 확인 (여기에 진짜 분석 정보가 있음)
        if (recordDocument is Map<String, dynamic> && recordDocument.containsKey('resultData')) {
          return recordDocument['resultData']; // 진짜 알맹이 리턴!
        }

        return recordDocument;
      }

      return decoded;
    } else {
      throw Exception('상세 정보를 불러오지 못했습니다.');
    }
  }
}