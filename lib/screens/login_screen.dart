import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';  // ✅ 추가


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final id = _idController.text.trim();
      final pw = _pwController.text.trim();

      await ApiService.sendUserId(id, pw);   // 로그인 요청

      // ✅ 로그인 성공했으니 세션에 아이디 저장
      UserSession.userId = id;

      // ✅ 홈으로 이동
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _error = "로그인 실패: $e";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF090015),
              Color(0xFF14082E),
              Color(0xFF090015),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 앱 로고 텍스트 (네온)
                  Text(
                    "VoiceTrain",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.purpleAccent.withOpacity(0.8),
                          blurRadius: 25,
                        ),
                        Shadow(
                          color: Colors.blueAccent.withOpacity(0.5),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // 아이디 입력
                  _neonTextField(
                    controller: _idController,
                    label: "아이디",
                    icon: Icons.person,
                  ),

                  const SizedBox(height: 20),

                  // 비밀번호 입력
                  _neonTextField(
                    controller: _pwController,
                    label: "비밀번호",
                    icon: Icons.lock,
                    obscure: true,
                  ),

                  const SizedBox(height: 20),
                  if (_error != null)
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),

                  const SizedBox(height: 30),

                  // 로그인 버튼
                  GestureDetector(
                    onTap: _isLoading ? null : _login,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: _isLoading
                              ? [
                            Colors.white24,
                            Colors.white10,
                          ]
                              : [
                            Colors.purpleAccent.withOpacity(0.9),
                            Colors.cyanAccent.withOpacity(0.7),
                          ],
                        ),
                        boxShadow: _isLoading
                            ? []
                            : [
                          BoxShadow(
                            color: Colors.purpleAccent.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.4),
                            blurRadius: 25,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          "로그인",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 회원가입 안내
                  Text(
                    "계정이 없나요? 곧 추가될 예정이에요!",
                    style: TextStyle(
                      color: Colors.white38,
                      shadows: [
                        Shadow(
                          color: Colors.purpleAccent.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 네온 스타일 텍스트필드
  Widget _neonTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white24,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.cyanAccent,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.cyanAccent),
          filled: true,
          fillColor: Colors.white.withOpacity(0.03),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.white30),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.cyanAccent),
          ),
        ),
      ),
    );
  }
}
