import 'package:app/controllers/style_controller.dart';
import 'package:app/utils/assets_util.dart';
import 'package:app/utils/route_utils.dart';
import 'package:app/views/ui/app_backgroud.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/record_controller.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, this.controller});
  final RecordScreenController? controller;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLogoVisible = true;
  double _position = 0;

  @override
  void initState() {
    super.initState();
  }

  void _clickNextStep() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isFirstLaunch", false);
    if (mounted) {
      context.pushReplacementNamed(RouteName.home_chat, );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isLightMode = themeNotifier.mode == Mode.light;

    TextStyle? textStyle = Theme.of(context).textTheme.displayMedium?.copyWith(
          color: isLightMode ? const Color(0xCC082E45) : Colors.white,
        );
    List<Widget> pages = [
      WelcomeText1(style: textStyle),
      WelcomeText2(style: textStyle),
      WelcomeText3(style: textStyle),
    ];
    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            SizedBox(height: 113.sp),
            SizedBox(
              width: 208.sp,
              height: 208.sp,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _isLogoVisible ? 1.0 : 0.0,
                  duration: const Duration(seconds: 1),
                  child: Image.asset(
                    AssetsUtil.logo,
                    width: 116.sp,
                    height: 116.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.sp),
            SizedBox(
              height: 284.sp,
              child: PageView(
                onPageChanged: (int index) {
                  setState(() {
                    _position = index.toDouble();
                  });
                },
                children: pages,
              ),
            ),
            if (_position < pages.length - 1)
              DotsIndicator(
                dotsCount: pages.length,
                position: _position,
                decorator: DotsDecorator(
                  color: isLightMode ? const Color(0x33000000) : const Color(0x33FFFFFF),
                  activeColor: isLightMode ? Colors.black : Colors.white,
                  size: Size.square(6.sp),
                  activeSize: Size(14.sp, 6.sp),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.sp),
                  ),
                ),
              )
            else
              NextStepButton(onPressed: _clickNextStep)
          ],
        ),
      ),
    );
  }
}

class WelcomeText1 extends StatelessWidget {
  final TextStyle? style;

  const WelcomeText1({super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Thank\nyou for choosing ',
        style: style,
        children: [
          TextSpan(
            text: 'Buddie!',
            style: style?.copyWith(color: const Color(0xFF29BBC6)),
          ),
        ],
      ),
    );
  }
}

class WelcomeText2 extends StatelessWidget {
  final TextStyle? style;

  const WelcomeText2({
    super.key,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'Discover recording, \nchatting, and journaling \nfeatures.',
      textAlign: TextAlign.center,
      style: style,
    );
  }
}

class WelcomeText3 extends StatelessWidget {
  final TextStyle? style;

  const WelcomeText3({
    super.key,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'Just a few simple steps to \ncomplete your setup.',
      textAlign: TextAlign.center,
      style: style,
    );
  }
}

class NextStepButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NextStepButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: const ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Color(0xFF29BBC6)),
      ),
      label: const Text(
        'next step',
        style: TextStyle(color: Colors.white),
      ),
      icon: const Icon(
        Icons.arrow_forward,
        color: Colors.white,
      ),
      iconAlignment: IconAlignment.end,
    );
  }
}
