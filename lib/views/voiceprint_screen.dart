import 'package:app/controllers/style_controller.dart';
import 'package:app/utils/assets_util.dart';
import 'package:app/utils/route_utils.dart';
import 'package:app/views/ui/bud_icon.dart';
import 'package:app/views/ui/container/bud_shadow_container.dart';
import 'package:app/views/ui/layout/bud_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/wakeword_constants.dart';
import '../controllers/voiceprint_controller.dart';

class WelcomeRecordScreen extends StatefulWidget {
  const WelcomeRecordScreen({super.key});

  @override
  State<WelcomeRecordScreen> createState() => _WelcomeRecordScreenState();
}

class _WelcomeRecordScreenState extends State<WelcomeRecordScreen> with SingleTickerProviderStateMixin {
  late WelcomeRecordController _controller;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _controller = WelcomeRecordController(
      onSetupComplete: () {
        context.pop();
      },
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _controller.init();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isLightMode = themeNotifier.mode == Mode.light;
    return BudScaffold(
      title: 'Voice setup',
      body: Padding(
        padding: EdgeInsets.only(
          left: 46.sp,
          right: 46.sp,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title Section
            TitleSection(isLightMode: isLightMode),
            SizedBox(height: 100.sp),
            // Dynamic Phrase Section
            DynamicPhraseSection(
              text: wakeword_constants.voiceVerificationPhrases[_controller.currentStep],
              isLightMode: isLightMode,
            ),
            SizedBox(height: 64.sp),
            // Speaking Indicator
            Center(
              child: _controller.isSpeaking
                  ? ScaleTransition(
                      scale: _animationController,
                      child: BudIcon(
                        icon: AssetsUtil.icon_voice_print_stop,
                        size: 97.sp,
                      ),
                    )
                  : BudIcon(
                      icon: AssetsUtil.icon_voice_print_record,
                      size: 97.sp,
                    ),
            ),
            const SizedBox(height: 40),
            AnimatedOpacity(
              opacity: _controller.recognitionFeedback.isNotEmpty ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300), // Duration of the fade in/out
              child: Text(
                _controller.recognitionFeedback,
                style: TextStyle(
                  fontSize: 16,
                  color: _controller.feedbackColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TitleSection extends StatelessWidget {
  final bool isLightMode;

  const TitleSection({
    super.key,
    required this.isLightMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Voice Setup',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 34,
            color: Color(0xFF29BBC6),
          ),
        ),
        SizedBox(height: 16.sp),
        Text(
          'Follow the prompts to complete your voice setup.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isLightMode ? const Color(0xFF1E1B33) : Colors.white,
          ),
        ),
      ],
    );
  }
}

class DynamicPhraseSection extends StatelessWidget {
  final String text;
  final bool isLightMode;

  const DynamicPhraseSection({
    super.key,
    required this.text,
    required this.isLightMode,
  });

  @override
  Widget build(BuildContext context) {
    return BudShadowContainer(
      radius: 12.sp,
      padding: EdgeInsets.symmetric(horizontal: 30.sp, vertical: 26.sp),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: isLightMode ? const Color(0xFF120D35) : Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
