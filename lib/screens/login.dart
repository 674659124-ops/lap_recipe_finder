import 'package:flutter/material.dart';
import '../services/app_data.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      AppData().login(email, password);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เข้าสู่ระบบสำเร็จ ยินดีต้อนรับ!'),
          backgroundColor: Color(0xFF207935),
          duration: Duration(seconds: 1),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _handleRegister() {
    final regNameController = TextEditingController();
    final regEmailController = TextEditingController();
    final regPasswordController = TextEditingController();
    final regConfirmPasswordController = TextEditingController();
    final regFormKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: regFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'สมัครสมาชิก (Register)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'สร้างบัญชีใหม่เพื่อเข้าใช้งานทุกฟังก์ชั่นในแอปพลิเคชัน',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Color(0xFF8C919E)),
                      ),
                      const SizedBox(height: 24),

                      // Name Field
                      TextFormField(
                        controller: regNameController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'กรุณากรอกชื่อ-นามสกุล' : null,
                        decoration: InputDecoration(
                          labelText: 'ชื่อ-นามสกุล',
                          hintText: 'เช่น ณัฐชา คุกกิ้ง',
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF207935)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF207935), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Email Field
                      TextFormField(
                        controller: regEmailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'กรุณากรอกอีเมล';
                          if (!v.contains('@') || !v.contains('.')) return 'รูปแบบอีเมลไม่ถูกต้อง';
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'อีเมล',
                          hintText: 'name@example.com',
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF207935)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF207935), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Password Field
                      TextFormField(
                        controller: regPasswordController,
                        obscureText: true,
                        validator: (v) => v == null || v.length < 6 ? 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร' : null,
                        decoration: InputDecoration(
                          labelText: 'รหัสผ่าน',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF207935)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF207935), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Confirm Password Field
                      TextFormField(
                        controller: regConfirmPasswordController,
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'กรุณายืนยันรหัสผ่าน';
                          if (v != regPasswordController.text) return 'รหัสผ่านไม่ตรงกัน';
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'ยืนยันรหัสผ่าน',
                          prefixIcon: const Icon(Icons.lock_reset_rounded, color: Color(0xFF207935)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF207935), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Confirm Register Button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            if (regFormKey.currentState?.validate() ?? false) {
                              AppData().register(
                                regNameController.text.trim(),
                                regEmailController.text.trim(),
                                regPasswordController.text.trim(),
                              );
                              Navigator.pop(context); // Close bottom sheet
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('สมัครสมาชิกสำเร็จเรียบร้อยแล้ว! เข้าสู่ระบบให้อัตโนมัติ'),
                                  backgroundColor: Color(0xFF207935),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const HomeScreen()),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF207935),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('ยืนยันสมัครสมาชิก', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleForgotPassword() {
    final resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ลืมรหัสผ่าน (Forgot Password)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('กรุณากรอกอีเมลของคุณเพื่อรับลิงก์รีเซ็ตรหัสผ่าน:', style: TextStyle(fontSize: 14, color: Color(0xFF6C727F))),
            const SizedBox(height: 14),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'your_email@example.com',
                prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF207935)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final email = resetEmailController.text.trim();
              if (email.isNotEmpty && email.contains('@')) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ส่งลิงก์รีเซ็ตรหัสผ่านไปยัง $email เรียบร้อยแล้ว'),
                    backgroundColor: const Color(0xFF207935),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('กรุณากรอกอีเมลให้ถูกต้อง')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF207935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('ส่งลิงก์'),
          ),
        ],
      ),
    );
  }

  void _handleGoogleSignIn() {
    AppData().googleSignIn();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('เข้าสู่ระบบด้วย Google เรียบร้อยแล้ว!'),
        backgroundColor: Color(0xFF207935),
        duration: Duration(seconds: 1),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF207935);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  // Logo / App Icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.12),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryGreen.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.restaurant_menu_rounded,
                        size: 46,
                        color: primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // App Title
                  const Text(
                    'Recipe Finder',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Welcome Heading
                  const Text(
                    'ยินดีต้อนรับ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Subtitle
                  const Text(
                    'เข้าสู่โลกแห่งสูตรอาหารแสนอร่อย',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7D848D),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email Input
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณากรอกอีเมล';
                      }
                      if (!value.contains('@')) {
                        return 'รูปแบบอีเมลไม่ถูกต้อง';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Email (เช่น natcha.cook@email.com)',
                      hintStyle: const TextStyle(color: Color(0xFFA0A6B1), fontSize: 14),
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF7D848D)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: primaryGreen, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกรหัสผ่าน';
                      }
                      if (value.length < 4) {
                        return 'รหัสผ่านต้องมีอย่างน้อย 4 ตัวอักษร';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Color(0xFFA0A6B1), fontSize: 15),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF7D848D)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: const Color(0xFF7D848D),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: primaryGreen, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'เข้าสู่ระบบ (Login)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Register Link
                  Center(
                    child: GestureDetector(
                      onTap: _handleRegister,
                      child: RichText(
                        text: const TextSpan(
                          text: 'ยังไม่มีบัญชี? ',
                          style: TextStyle(
                            color: Color(0xFF6C727F),
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'สมัครสมาชิก (Register)',
                              style: TextStyle(
                                color: primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Forgot Password Link
                  Center(
                    child: GestureDetector(
                      onTap: _handleForgotPassword,
                      child: const Text(
                        'ลืมรหัสผ่าน (Forgot Password)?',
                        style: TextStyle(
                          color: Color(0xFF6C727F),
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF6C727F),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Divider "หรือ"
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'หรือ',
                          style: TextStyle(
                            color: Color(0xFF8C919E),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Google Sign In Button
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _handleGoogleSignIn,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildGoogleIcon(),
                          const SizedBox(width: 12),
                          const Text(
                            'ดำเนินการต่อด้วย Google',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3142),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double radius = w / 2;

    final redPaint = Paint()..color = const Color(0xFFEA4335);
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final greenPaint = Paint()..color = const Color(0xFF34A853);
    final bluePaint = Paint()..color = const Color(0xFF4285F4);

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    canvas.drawArc(rect, -0.785, 2.356, true, redPaint);
    canvas.drawArc(rect, 1.571, 1.178, true, yellowPaint);
    canvas.drawArc(rect, 0.393, 1.178, true, greenPaint);
    canvas.drawArc(rect, -0.785, 1.178, true, bluePaint);

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), radius * 0.55, innerPaint);

    final blueRect = Rect.fromLTRB(cx, cy - radius * 0.22, cx + radius, cy + radius * 0.22);
    canvas.drawRect(blueRect, bluePaint);

    final cutRect = Rect.fromLTRB(cx - radius * 0.1, cy - radius * 0.22, cx + radius * 0.2, cy + radius * 0.22);
    canvas.drawRect(cutRect, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
