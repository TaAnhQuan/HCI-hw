import 'package:app/controllers/style_controller.dart';
import 'package:app/utils/assets_util.dart';
import 'package:app/utils/route_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class JournalHome extends StatelessWidget {
  const JournalHome({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    Mode mode = themeNotifier.mode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HelloText(mode: mode),
        SizedBox(height: 16.sp),
        GridEntry(mode: mode),
      ],
    );
  }
}

class HelloText extends StatelessWidget {
  final Mode mode;

  const HelloText({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        fontSize: 34.sp,
        fontWeight: FontWeight.bold,
        color: mode == Mode.light ? Colors.black : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hello'),
          const Text('buddie!'),
          SizedBox(height: 34.sp),
          Text(
            'continue French!',
            style: TextStyle(fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
}

class GridEntry extends StatelessWidget {
  final Mode mode;

  const GridEntry({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16.sp,
      runSpacing: 16.sp,
      children: [
        GridItem(
          onTap: () => context.pushNamed(RouteName.meeting_list),
          bgColors: const [
            Color(0xFFDAD9FA),
            Color(0xFFEFECFD),
            Color(0xFFE1DCF7),
          ],
          icon: AssetsUtil.getIconPath(mode: mode, icon: AssetsUtil.icon_journal_grid_contents),
          title: 'Meeting Summary',
        ),
        GridItem(
          onTap: () => context.pushNamed(RouteName.daily_list),
          bgColors: const [
            Color(0xFFD9E8FA),
            Color(0xFFECF2FD),
            Color(0xFFDCE4F7),
          ],
          icon: AssetsUtil.getIconPath(mode: mode, icon: AssetsUtil.icon_journal_grid_daily),
          title: 'Daily Summary',
        ),
        GridItem(
          onTap: () => context.pushNamed(RouteName.todo_list),
          bgColors: const [
            Color(0xFFD9F7FA),
            Color(0xFFECFAFD),
            Color(0xFFDCEFF7),
          ],
          icon: AssetsUtil.getIconPath(mode: mode, icon: AssetsUtil.icon_journal_grid_todo),
          title: 'to-do list',
        ),
        GridItem(
          onTap: () => context.pushNamed(RouteName.user_model),
          bgColors: const [
            Color(0xFFD9F7FA),
            Color(0xFFECFAFD),
            Color(0xFFDCEFF7),
          ],
          icon: AssetsUtil.getIconPath(mode: mode, icon: AssetsUtil.icon_user),
          title: 'User model',
        ),
      ],
    );
  }
}

class GridItem extends StatelessWidget {
  final List<Color> bgColors;
  final String icon;
  final String title;
  final GestureTapCallback? onTap;

  const GridItem({
    super.key,
    required this.bgColors,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isLightMode = themeNotifier.mode == Mode.light;
    return InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: isLightMode ? 1 : 0.7,
        child: SizedBox(
          width: 159.sp,
          height: 112.sp,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 98.sp,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: bgColors,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 16.sp,
                  bottom: 12.sp,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      icon,
                      width: 58.sp,
                      height: 46.sp,
                    ),
                    SizedBox(height: 12.sp),
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0x6619153D),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
