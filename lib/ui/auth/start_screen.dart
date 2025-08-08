import 'package:flutter/material.dart';
import 'package:uptodo/ui/onboarding/onboarding_page_view.dart';
import 'package:uptodo/ui/home/home_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  void _backToOnboarding(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF8E7CFF);
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return WillPopScope(
      onWillPop: () async {
        _backToOnboarding(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => _backToOnboarding(context),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Chào mừng bạn đến với UpTodo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Vui lòng đăng nhập tài khoản hoặc tạo\n'
                    'tài khoản mới để tiếp tục',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const Spacer(),

              // ĐĂNG NHẬP -> sang HomeScreen
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'ĐĂNG NHẬP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ĐĂNG KÝ
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đăng ký – tính năng sẽ cập nhật sau')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primary, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'ĐĂNG KÝ',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
