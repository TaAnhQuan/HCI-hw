import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../controllers/style_controller.dart';
import '../../models/tool_button.dart';
import '../../utils/assets_util.dart';
import '../ui/bud_icon.dart';

class ChatTextField extends StatefulWidget {
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;
  final GestureTapCallback? onTapKeyboard;
  final GestureTapCallback? onTapSend;
  final GestureTapCallback? onTapTool; // optional external callback
  final Color colorOn;
  final Color colorOff;

  const ChatTextField({
    super.key,
    this.focusNode,
    this.controller,
    this.onSubmitted,
    this.onTapKeyboard,
    this.onTapSend,
    this.onTapTool,
    this.colorOn = Colors.green,
    this.colorOff = Colors.grey,
  });

  @override
  State<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  late final ToolButtonModel _toolModel;

  @override
  void initState() {
    super.initState();
    _toolModel = ToolButtonModel();
  }

  @override
  void dispose() {
    _toolModel.dispose();
    super.dispose();
  }

  void _handleToolTap() {
    // 1) Toggle the model so AnimatedBuilder rebuilds with new color
    _toolModel.toggle();

    // 2) If caller passed an onTapTool, invoke it too
    widget.onTapTool?.call();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isLightMode = themeNotifier.mode == Mode.light;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: isLightMode ? const Color(0x99FFFFFF) : const Color(0xFF333333),
      ),
      padding: EdgeInsets.only(left: 8.sp, right: 12.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // … (you can uncomment the keyboard icon section if needed) …

          // Tool button with dynamic color
          Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: AnimatedBuilder(
              animation: _toolModel,
              builder: (context, _) {
                final iconColor =
                _toolModel.isOn ? widget.colorOn : widget.colorOff;
                return InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: _handleToolTap,
                  child: Icon(
                    Icons.settings_suggest_sharp,
                    size: 22,
                    color: iconColor,
                  ),
                );
              },
            ),
          ),

          SizedBox(width: 12.sp),

          Expanded(
            child: TextField(
              focusNode: widget.focusNode,
              controller: widget.controller,
              onSubmitted: widget.onSubmitted,
              minLines: 1,
              maxLines: 9,
              textInputAction: TextInputAction.send,
              style: TextStyle(
                color: isLightMode ? Colors.black : Colors.white,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your message...',
                hintStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isLightMode
                      ? const Color(0xFF999999)
                      : const Color(0x99FFFFFF),
                ),
              ),
            ),
          ),

          SizedBox(width: 12.sp),

          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: widget.onTapSend,
              child: const BudIcon(
                icon: AssetsUtil.icon_send_message,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
