import 'dart:convert';

import 'package:app/controllers/style_controller.dart';
import 'package:app/extension/datetime_extension.dart';
import 'package:app/services/objectbox_service.dart';
import 'package:app/utils/assets_util.dart';
import 'package:app/views/components/audio_player.dart';
import 'package:app/views/meeting/meeting_list_screen.dart';
import 'package:app/views/ui/bud_expansion_text.dart';
import 'package:app/views/ui/bud_icon.dart';
import 'package:app/views/ui/bud_tab_bar.dart';
import 'package:app/views/ui/layout/bud_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MeetingDetailScreen extends StatefulWidget {
  final MeetingModel model;

  const MeetingDetailScreen({
    super.key,
    required this.model,
  });

  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen> {
  final List<String> _tabs = [
    'Records',
    'Summary',
  ];

  void _onClickShare() {}

  void _onClickMore() {}

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isLightMode = themeNotifier.mode == Mode.light;
    return DefaultTabController(
      length: _tabs.length,
      child: BudScaffold(
        title: 'meeting',
        actions: [
          InkWell(
            onTap: _onClickShare,
            child: BudIcon(
              icon: AssetsUtil.icon_btn_share,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.sp),
          InkWell(
            onTap: _onClickMore,
            child: BudIcon(
              icon: AssetsUtil.icon_btn_more,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 10.sp),
        ],
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isLightMode ? Colors.white : const Color(0xFF141414),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 21.sp,
                      left: 16.sp,
                      right: 16.sp,
                      bottom: 16.sp,
                    ),
                    child: const AudioPlayer(
                      assetsPath: 'assets/audios/interruption.wav',
                    ),
                  ),
                  BudTabBar(tabs: _tabs),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ConvertVoiceWidget(
                    list: ObjectBoxService().getRecordsByTimeRange(widget.model.startTime, widget.model.endTime).map(
                      (record) => VoiceModel(
                        name: record.role!,
                        avatar: '',
                        timestamp: DateTime.fromMillisecondsSinceEpoch(record.createdAt!).toTimeFormatString(),
                        content: record.content!)
                    ).toList()
                  ),
                  SummaryWidget(dateTime: widget.model.datetime, content: widget.model.fullContent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VoiceModel {
  final String name;

  bool get isMe => name == '发言人1';
  final String avatar;
  final String timestamp;
  final String content;

  VoiceModel({
    required this.name,
    required this.avatar,
    required this.timestamp,
    required this.content,
  });
}

class ConvertVoiceWidget extends StatelessWidget {
  final List<VoiceModel> list;

  const ConvertVoiceWidget({
    super.key,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.only(top: 16.sp),
      itemCount: list.length,
      separatorBuilder: (_, index) => SizedBox(height: 16.sp),
      itemBuilder: (_, index) {
        VoiceModel model = list[index];
        return ConvertVoiceListTile(model: model);
      },
    );
  }
}

class ConvertVoiceListTile extends StatelessWidget {
  final VoiceModel model;
  final GestureTapCallback? onTapPlay;

  const ConvertVoiceListTile({
    super.key,
    required this.model,
    this.onTapPlay,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isLightMode = themeNotifier.mode == Mode.light;
    Widget playButton = InkWell(
      onTap: onTapPlay,
      child: BudIcon(
        icon: AssetsUtil.icon_play_section,
        size: 14.sp,
      ),
    );
    Widget avatar = BudIcon(
      icon: model.isMe ? AssetsUtil.icon_spokesperson_1 : AssetsUtil.icon_spokesperson_2,
      size: 16.sp,
    );
    TextStyle textStyle = const TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 14,
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.sp),
      child: Column(
        crossAxisAlignment: model.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: model.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (model.isMe) playButton else avatar,
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.sp),
                  child: Text(
                    '${model.name}  ${model.timestamp}',
                    style: textStyle.copyWith(
                      color: isLightMode ? const Color(0xCC000000) : const Color(0xCCFFFFFF),
                    ),
                  ),
                ),
              ),
              if (model.isMe) avatar else playButton,
            ],
          ),
          SizedBox(height: 12.sp),
          Text(
            model.content,
            textAlign: model.isMe ? TextAlign.right : TextAlign.left,
            style: textStyle.copyWith(
              color: isLightMode ? Colors.black : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryWidget extends StatelessWidget {
  final DateTime? dateTime;
  final String? content;

  const SummaryWidget({
    super.key,
    this.dateTime,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isLightMode = themeNotifier.mode == Mode.light;
    String? datetime = dateTime?.toDateFormatString(
      dateSplit: '.',
      datetimeSplit: ' ',
    );
    TextStyle titleTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: isLightMode ? Colors.black : Colors.white,
    );
    return Padding(
      padding: EdgeInsets.only(
        left: 16.sp,
        right: 16.sp,
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.sp),
            child: Row(
              children: [
                BudIcon(
                  icon: AssetsUtil.icon_clock_2,
                  size: 14.sp,
                ),
                SizedBox(width: 4.sp),
                Text(
                  '$datetime record',
                  style: titleTextStyle,
                ),
              ],
            ),
          ),
          ExpansionCard(
            icon: AssetsUtil.icon_summary_1,
            title: 'Full text summary',
            content: jsonDecode(content!)['abstract'],
          ),
          SizedBox(height: 12.sp),
          ExpansionCard(
            icon: AssetsUtil.icon_summary_2,
            title: 'Chapter Overview',
            content: jsonDecode(content!)['sections'].toString()
          ),
          SizedBox(height: 12.sp),
          ExpansionCard(
            icon: AssetsUtil.icon_summary_3,
            title: 'Key points review',
            content: jsonDecode(content!)['key_points'].toString(),
          ),
        ],
      ),
    );
  }
}

class ExpansionCard extends StatefulWidget {
  final String icon;
  final String title;
  final String content;

  const ExpansionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  State<ExpansionCard> createState() => _ExpansionCardState();
}

class _ExpansionCardState extends State<ExpansionCard> {
  bool _isAll = false;

  void _onClickArrow() {
    setState(() {
      _isAll = !_isAll;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isLightMode = themeNotifier.mode == Mode.light;
    return Container(
      padding: EdgeInsets.only(
        top: 8.sp,
        left: 16.sp,
        right: 16.sp,
        bottom: 12.sp,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.sp),
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
                ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              BudIcon(
                icon: widget.icon,
                size: 12.sp,
              ),
              SizedBox(width: 8.sp),
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isLightMode ? Colors.black : Colors.white,
                ),
              )
            ],
          ),
          SizedBox(height: 8.sp),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 10.sp),
            decoration: BoxDecoration(
              color: isLightMode ? Colors.white : const Color(0x12FFFFFF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: BudExpansionText(
              expanded: _isAll,
              text: widget.content,
              maxLines: 2,
              style: TextStyle(
                fontSize: 14,
                color: isLightMode ? const Color(0xFF666666) : const Color(0x99FFFFFF),
              ),
            ),
          ),
          SizedBox(height: 8.sp),
          InkWell(
            onTap: _onClickArrow,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _isAll ? 'retract' : 'ALL',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: isLightMode ? Colors.black : Colors.white,
                  ),
                ),
                SizedBox(width: 3.sp),
                BudIcon(
                  icon: _isAll ? AssetsUtil.icon_arrow_up : AssetsUtil.icon_arrow_down,
                  size: 8.sp,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
