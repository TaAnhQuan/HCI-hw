import 'package:app/controllers/style_controller.dart';
import 'package:app/views/journal/daily_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class DailySearchListView extends StatelessWidget {
  final List<DailyModel>? list;

  const DailySearchListView({
    super.key,
    this.list,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isLightMode = themeNotifier.mode == Mode.light;
    return Column(
      children: [
        if (list != null && list!.isNotEmpty)
          DailyListView(
            shrinkWrap: true,
            list: list!,
          ),
        if (list == null || list!.isEmpty)
          SizedBox(height: 40.sp),
          Text(
            'No matches found',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: isLightMode ? const Color(0x66000000) : const Color(0x66FFFFFF),
            ),
          ),
      ],
    );
  }
}
