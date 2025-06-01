import 'package:app/views/components/chat_bottom_buttons.dart';
import 'package:app/views/components/chat_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeBottomBar extends StatelessWidget {
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;

  final GestureTapCallback? onTapSend;
  final GestureTapCallback? onTapKeyboard;
  final GestureTapCallback? onTapTool;

  final GestureTapCallback? onTapLeft;
  final GestureTapCallback? onTapHelp;
  final GestureTapCallback? onTapRight;

  final bool isRecording;
  final ValueNotifier<bool> isSpeakValueNotifier;

  const HomeBottomBar({
    super.key,
    this.focusNode,
    this.controller,
    this.onSubmitted,
    this.onTapSend,
    this.onTapTool,
    this.onTapKeyboard,
    this.onTapLeft,
    this.onTapHelp,
    this.onTapRight,
    required this.isRecording,
    required this.isSpeakValueNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ChatTextField(
          focusNode: focusNode,
          controller: controller,
          onTapKeyboard: onTapKeyboard,
          onSubmitted: onSubmitted,
          onTapSend: onTapSend,
          onTapTool: onTapTool,
        ),
        SizedBox(height: 8.sp),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.sp),
          child: ChatBottomButtons(
            onTapLeft: onTapLeft,
            onTapHelp: onTapHelp,
            onTapRight: onTapRight,
            isRecording: isRecording,
            isSpeakValueNotifier: isSpeakValueNotifier,
          ),
        ),
      ],
    );
  }
}