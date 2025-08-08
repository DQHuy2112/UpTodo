import 'package:flutter/material.dart';
import 'package:uptodo/ui/onboarding/onboarding_page_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121212),
      body: SafeArea(child: _BuildBodyPage()),
    );
  }
}

class _BuildBodyPage extends StatelessWidget {
  const _BuildBodyPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BuildIconSplash(),
          _BuildTextSplash(),
        ],
      ),
    );
  }
}

class _BuildIconSplash extends StatelessWidget {
  const _BuildIconSplash();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/icon.png",
      width: 95,
      height: 80,
      fit: BoxFit.contain,
    );
  }
}

class _BuildTextSplash extends StatelessWidget {
  const _BuildTextSplash();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 20),
      child: Text(
        "UpTodo",
        style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
