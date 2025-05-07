import 'package:app/utils/assets_util.dart';
import 'package:app/utils/route_utils.dart';
import 'package:app/views/components/member_progress_indicator.dart';
import 'package:app/views/ui/bud_card.dart';
import 'package:app/views/ui/bud_icon.dart';
import 'package:app/views/ui/bud_switch.dart';
import 'package:app/views/ui/layout/bud_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/export_controller.dart';
import '../controllers/style_controller.dart';
import '../controllers/setting_controller.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final SettingScreenController _controller = SettingScreenController();
  String fileContent = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.attach(this);
  }

  void _onClickUser() {
    context.pushNamed(RouteName.user);
  }

  void _onClickResetVoicePrint() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Reset'),
          content: const Text('Do you want to reset your voiceprint sample?'),
          actions: [
            TextButton(
              onPressed: () {
                context.pop(false);
              },
              child: const Text('NO'),
            ),
            TextButton(
              onPressed: () {
                context.pop(true);
              },
              child: const Text('YES'),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      _controller.resetVoiceprint();
      context.pushNamed(RouteName.voice_print);
      return;
    }
  }

  /// Navigate to privacy settings or show a dialog
  void _onClickPrivacy() {}

  void _onClickExportData() {
    showDialog(
      context: context,
      builder: (context) {
        return ExportDataDialog();
      },
    );
  }

  void _onClickAbout() {
    context.pushNamed(RouteName.about);
  }


  void _onClickSetup() {}

  void _onClickHelpAndFeedback() {}

  void _onClickPrivacyAndProtocol() {}

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return BudScaffold(
      title: 'Settings',
      actions: [
        InkWell(
          onTap: _onClickUser,
          child: Image.asset(
            AssetsUtil.getIconPath(
              mode: themeNotifier.mode,
              icon: AssetsUtil.icon_user,
            ),
            width: 24.sp,
            height: 24.sp,
          ),
        ),
        SizedBox(width: 16.sp),
      ],
      body: ListView(
        padding: EdgeInsets.all(16.sp),
        children: [
          const MemberWidget(
            remainMinute: 260,
            totalMinute: 300,
          ),
          SizedBox(height: 12.sp),
          SectionListView(
            children: [
              SettingListTile(
                leading: AssetsUtil.icon_setting_always_on,
                title: 'Always On',
                trailing: BudSwitch(
                  value: _controller.isAlwaysOn,
                  onChanged: (value) {
                    if (_controller.isSwitchEnabled) {
                      _controller.toggleAlwaysOn(value);
                    }
                  },
                ),
              ),
              SettingListTile(
                leading: AssetsUtil.icon_dark_mode,
                title: 'Dark Mode',
                trailing: BudSwitch(
                  value: themeNotifier.mode == Mode.dark,
                  onChanged: (value) {
                    themeNotifier.toggleTheme();
                  },
                ),
              ),
              SettingListTile(
                onTap: _onClickResetVoicePrint,
                leading: AssetsUtil.icon_voice_print,
                title: 'Reset Voiceprint',
                subtitle: 'Reset your voiceprint sample',
              ),
              SettingListTile(
                leading: AssetsUtil.icon_export_data,
                title: 'Export Data',
                subtitle: 'Export transcription results',
                onTap: _onClickExportData,
              ),
            ],
          ),
          SizedBox(height: 12.sp),
          SectionListView(children: [
            SettingListTile(
              leading: AssetsUtil.icon_about,
              title: 'About',
              subtitle: 'Learn more about this app',
              onTap: _onClickAbout,
            ),
            SettingListTile(
              leading: AssetsUtil.icon_set_up,
              title: 'Set Up',
              onTap: _onClickSetup,
            ),
            SettingListTile(
              leading: AssetsUtil.icon_feedback,
              title: 'Help and Feedback',
              onTap: _onClickHelpAndFeedback,
            ),
            SettingListTile(
              leading: AssetsUtil.icon_privacy,
              title: 'Privacy Policy',
              subtitle: 'Manage privacy settings',
              onTap: _onClickPrivacy,
            ),
            SettingListTile(
              leading: AssetsUtil.icon_protocol,
              title: 'User Agreement',
              onTap: _onClickPrivacyAndProtocol,
            ),
          ]),
        ],
      ),
    );
  }
}

class MemberWidget extends StatelessWidget {
  final int remainMinute;
  final int totalMinute;

  const MemberWidget({
    super.key,
    required this.remainMinute,
    required this.totalMinute,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isLightMode = themeNotifier.mode == Mode.light;
    return BudCard(
      radius: 8.sp,
      color: isLightMode ? const Color(0xFFEAEAEA) : const Color(0x33FFFFFF),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.sp),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Buddie member',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isLightMode ? const Color.fromRGBO(0, 0, 0, 0.6) : const Color(0xFF29BBC6),
                    ),
                  ),
                ),
                BudIcon(
                  icon: AssetsUtil.icon_arrow_forward_2,
                  size: 14.sp,
                ),
              ],
            ),
          ),
          BudCard(
            radius: 8.sp,
            color: isLightMode ? const Color(0xFF3D4A4F) : const Color(0xFF0A1F21),
            padding: EdgeInsets.all(12.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Beginner Members',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 3.sp),
                    BudIcon(
                      icon: AssetsUtil.icon_star,
                      size: 12.sp,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: MemberLinearProgressIndicator(value: remainMinute / totalMinute),
                ),
                Text(
                  '$remainMinute minutes remaining (out of $totalMinute minutes)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color.fromRGBO(255, 255, 255, 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionListView extends StatelessWidget {
  final List<Widget> children;

  const SectionListView({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isLightMode = themeNotifier.mode == Mode.light;
    return BudCard(
      color: isLightMode ? const Color(0xFFFAFAFA) : const Color(0x33FFFFFF),
      radius: 8.sp,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 32.sp),
        itemCount: children.length,
        separatorBuilder: (_, index) => const Divider(
          height: 1,
          color: Color.fromRGBO(0, 0, 0, 0.1),
        ),
        itemBuilder: (_, index) => children[index],
      ),
    );
  }
}

class SettingListTile extends StatelessWidget {
  final String leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final GestureTapCallback? onTap;

  const SettingListTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isLightMode = themeNotifier.mode == Mode.light;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 70.sp,
        padding: EdgeInsets.symmetric(vertical: 14.sp),
        child: Row(
          children: [
            BudCard(
              color: isLightMode ? const Color(0xFFEEEEEE) : const Color(0x1AEEEEEE),
              radius: 5.sp,
              padding: EdgeInsets.all(5.sp),
              child: BudIcon(
                icon: leading,
                size: 14.sp,
              ),
            ),
            SizedBox(width: 16.sp),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isLightMode ? Colors.black : Colors.white,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isLightMode ? const Color(0xFF999999) : const Color(0x99FFFFFF),
                      ),
                    )
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
