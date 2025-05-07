import 'package:app/utils/assets_util.dart';
import 'package:app/views/ui/button/bud_shadow_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatBottomButtons extends StatelessWidget {
  final GestureTapCallback? onTapLeft;
  final GestureTapCallback? onTapHelp;
  final GestureTapCallback? onTapRight;
  final bool isRecording;

  const ChatBottomButtons({
    super.key,
    this.onTapLeft,
    this.onTapHelp,
    this.onTapRight,
    required this.isRecording
  });

  static double height = 52.sp;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BudShadowButton(
            onTap: onTapLeft,
            icon: isRecording ? AssetsUtil.icon_btn_recording : AssetsUtil.icon_btn_record,
          ),
          SizedBox(width: 22.sp),
          Expanded(
            child: BudShadowButton(
              onTap: onTapHelp,
              icon: AssetsUtil.icon_btn_logo,
              text: 'Help me buddie',
            ),
          ),
          SizedBox(width: 22.sp),
          BudShadowButton(
            onTap: onTapRight,
            icon: AssetsUtil.icon_btn_journal,
          ),
        ],
      ),
    );
  }
}
