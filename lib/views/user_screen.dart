import 'package:app/controllers/style_controller.dart';
import 'package:app/utils/assets_util.dart';
import 'package:app/views/ui/app_backgroud.dart';
import 'package:app/views/ui/button/bud_button.dart';
import 'package:app/views/ui/bud_icon.dart';
import 'package:app/views/ui/layout/bud_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String _nickname = 'hejin huang';

  void _onClickNickName() {}

  void _onClickLoginMethod() {}

  void _onClickManageMyLogin() {}

  void _onClickLogOut() {}

  void _onClickDeleteAccount() {}

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isLightMode = themeNotifier.mode == Mode.light;
    TextStyle style = TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 16.sp,
      color: isLightMode ? const Color(0xFF333333) : Colors.white,
    );
    return BudScaffold(
      title: 'homepage',
      body: AppBackground(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.sp,
            right: 16.sp,
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            children: [
              SizedBox(height: 46.sp),
              Center(
                child: UserAvatar(
                  nickname: _nickname,
                ),
              ),
              ListTile(
                onTap: _onClickNickName,
                title: Row(
                  children: [
                    Text(
                      'Nickname',
                      style: style,
                    ),
                    const Spacer(),
                    Text(
                      _nickname,
                      style: style.copyWith(color: const Color(0xFF999999)),
                    ),
                  ],
                ),
                trailing: BudIcon(
                  icon: AssetsUtil.icon_arrow_forward_3,
                  size: 14.sp,
                ),
              ),
              ListTile(
                onTap: _onClickLoginMethod,
                title: Text(
                  'Login method',
                  style: style,
                ),
                trailing: BudIcon(
                  icon: AssetsUtil.icon_arrow_forward_3,
                  size: 14.sp,
                ),
              ),
              ListTile(
                onTap: _onClickManageMyLogin,
                title: Text(
                  'Manage my login',
                  style: style,
                ),
                trailing: BudIcon(
                  icon: AssetsUtil.icon_arrow_forward_3,
                  size: 14.sp,
                ),
              ),
              SizedBox(height: 54.sp),
              BudButton(
                onTap: _onClickLogOut,
                text: 'Log Out',
              ),
              const Spacer(),
              BudButton(
                onTap: _onClickDeleteAccount,
                text: 'Delete Account',
                color: const Color(0xFFDB595F),
              ),
              SizedBox(height: 12.sp),
              const WarningText(),
            ],
          ),
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String nickname;

  const UserAvatar({
    super.key,
    required this.nickname,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isLightMode = themeNotifier.mode == Mode.light;
    return ClipOval(
      child: Container(
        width: 72.sp,
        height: 72.sp,
        color: const Color(0xFF29BBC6),
        alignment: Alignment.center,
        child: Text(
          nickname.substring(0, 1).toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 34,
            color: isLightMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class WarningText extends StatelessWidget {
  const WarningText({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isLightMode = themeNotifier.mode == Mode.light;
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Warning: ',
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: Color(0xFFDB595F),
        ),
        children: [
          TextSpan(
            text: 'Your account information and all files will be \npermanently deleted.',
            style: TextStyle(
              color: isLightMode ? const Color(0x99000000) : const Color(0x99FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}
