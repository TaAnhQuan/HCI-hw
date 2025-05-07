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

class DailyModel {
  final String recordDateTime;

  DateTime? get datetime => recordDateTime.toDateTime();

  String? get formatRecordString {
    if (datetime == null) return null;
    return '${datetime!.year}-${datetime!.month}-${datetime!.day} ${datetime!.hour}:${datetime!.minute}';
  }

  final String content;
  final String fullContent;

  DailyModel({
    required this.recordDateTime,
    required this.content,
    required this.fullContent
  });
}

class DailyListScreen extends StatefulWidget {
  const DailyListScreen({super.key});

  @override
  State<DailyListScreen> createState() => _DailyListScreenState();
}

class _DailyListScreenState extends State<DailyListScreen> {
  List<DailyModel> _list = [];

  @override
  void initState() {
    super.initState();
    _initList();
  }

  /// Mock
  void _initList() {
    setState(() {
      final results = ObjectBoxService().getSummaries();
      _list = results?.map((record) => DailyModel(
          recordDateTime: DateTime.fromMillisecondsSinceEpoch(record.startTime).toDateFormatString() ,
          content: record.content!,
          fullContent: record.content!
      )).toList() ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return BudScaffold(
      title: 'Daily',
      body: DailyListView(list: _list),
    );
  }
}

class DailyListView extends StatelessWidget {
  final bool shrinkWrap;
  final List<DailyModel> list;

  const DailyListView({
    super.key,
    this.shrinkWrap = false,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      padding: EdgeInsets.all(16.sp),
      itemCount: list.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.sp),
      itemBuilder: (context, index) {
        DailyModel model = list[index];
        return DailyListTile(
          model: model,
          onTap: () {},
        );
      },
    );
  }
}

class DailyListTile extends StatelessWidget {
  final DailyModel model;
  final GestureTapCallback? onTap;

  const DailyListTile({
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
            '${model.formatRecordString ?? ''}',
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
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isLightMode ? const Color(0xFF999999) : const Color(0x99FFFFFF),
                ),
                child: Row(
                  children: [
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
