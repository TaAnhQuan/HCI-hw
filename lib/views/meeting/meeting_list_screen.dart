import 'dart:convert';

import 'package:app/controllers/style_controller.dart';
import 'package:app/extension/datetime_extension.dart';
import 'package:app/extension/duration_extension.dart';
import 'package:app/extension/string_extension.dart';
import 'package:app/services/objectbox_service.dart';
import 'package:app/utils/assets_util.dart';
import 'package:app/utils/route_utils.dart';
import 'package:app/views/ui/bud_icon.dart';
import 'package:app/views/ui/layout/bud_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MeetingModel {
  final String recordDateTime;

  DateTime? get datetime => recordDateTime.toDateTime();

  String? get formatRecordString {
    if (datetime == null) return null;
    return '${datetime!.year}-${datetime!.month}-${datetime!.day} ${datetime!.hour}:${datetime!.minute}';
  }

  final String content;
  final String fullContent;
  final String duration;

  final int startTime;
  final int endTime;

  MeetingModel({
    required this.recordDateTime,
    required this.content,
    required this.duration,
    required this.startTime,
    required this.endTime,
    required this.fullContent
  });
}

class MeetingListScreen extends StatefulWidget {
  const MeetingListScreen({super.key});

  @override
  State<MeetingListScreen> createState() => _MeetingListScreenState();
}

class _MeetingListScreenState extends State<MeetingListScreen> {
  List<MeetingModel> _list = [];

  @override
  void initState() {
    super.initState();
    _initList();
  }

  /// Mock
  void _initList() {
    setState(() {
      final results = ObjectBoxService().getMeetingSummaries();
      _list = results?.map((record) => MeetingModel(
        recordDateTime: DateTime.fromMillisecondsSinceEpoch(record.startTime).toDateFormatString() ,
        duration: Duration(milliseconds: (record.endTime - record.startTime)).toTimeFormatString(),
        content: jsonDecode(record.content!)['abstract'],
        startTime: record.startTime,
        endTime: record.endTime,
        fullContent: record.content!
      )).toList() ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return BudScaffold(
      title: 'meeting',
      body: MeetingListView(list: _list),
    );
  }
}

class MeetingListView extends StatelessWidget {
  final bool shrinkWrap;
  final List<MeetingModel> list;

  const MeetingListView({
    super.key,
    this.shrinkWrap = false,
    required this.list,
  });

  void _onClickItem({required BuildContext context, required MeetingModel item}) {
    context.pushNamed(
      RouteName.meeting_detail,
      extra: item,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      padding: EdgeInsets.all(16.sp),
      itemCount: list.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.sp),
      itemBuilder: (context, index) {
        MeetingModel model = list[index];
        return MeetingListTile(
          model: model,
          onTap: () {
            _onClickItem(context: context, item: model);
          },
        );
      },
    );
  }
}

class MeetingListTile extends StatelessWidget {
  final MeetingModel model;
  final GestureTapCallback? onTap;

  const MeetingListTile({
    super.key,
    required this.model,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isLightMode = themeNotifier.mode == Mode.light;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isLightMode ? null : const Color(0x33FFFFFF),
          gradient: isLightMode
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFEDFEFF),
                    Color(0xFFFFFFFF),
                  ],
                )
              : null,
          boxShadow: [
            isLightMode
                ? const BoxShadow(
                    color: Color(0x172A9ACA),
                    offset: Offset(0, 4),
                    blurRadius: 9,
                  )
                : const BoxShadow(
                    color: Color(0x1AA2EDF3),
                    blurRadius: 20,
                  )
          ],
        ),
        child: ListTile(
          title: Text(
            '${model.formatRecordString ?? ''} Meeting',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: isLightMode ? Colors.black : Colors.white,
            ),
          ),
          subtitle: Column(
            children: [
              Text(
                model.content,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isLightMode ? const Color(0xFF666666) : const Color(0x99FFFFFF),
                ),
              ),
              SizedBox(height: 12.sp),
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isLightMode ? const Color(0xFF999999) : const Color(0x99FFFFFF),
                ),
                child: Row(
                  children: [
                    BudIcon(
                      icon: AssetsUtil.icon_clock_1,
                      size: 14.sp,
                    ),
                    Text(' duration ${model.duration}'),
                    const Spacer(),
                    Text(model.datetime?.toDateFormatString(showTime: false, dateSplit: '/') ?? ''),
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
