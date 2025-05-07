import 'package:app/extension/datetime_extension.dart';
import 'package:app/utils/assets_util.dart';
import 'package:app/views/meeting/meeting_list_screen.dart';
import 'package:app/views/journal/daily_search_list_view.dart';
import 'package:app/views/journal/journal_home.dart';
import 'package:app/views/ui/app_backgroud.dart';
import 'package:app/views/ui/bud_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

import '../services/objectbox_service.dart';
import 'journal/daily_list_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  bool _onSearch = false;
  List<DailyModel>? _searchResultLit;

  void _onSearchSubmitted(String query) {
    setState(() {
      if (query.isNotEmpty) {
        _onSearch = true;
        final results = ObjectBoxService().getSummariesByKeyword(query);
        _searchResultLit = results?.map((record) => DailyModel(
            recordDateTime: DateTime.fromMillisecondsSinceEpoch(record.startTime).toDateFormatString() ,
            content: record.content!,
            fullContent: record.content!
        )).toList() ?? [];
      } else {
        _onSearch = false;
        _searchResultLit = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        body: AppBackground(
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 16.sp,
                  left: 16.sp,
                  right: 16.sp,
                ),
                child: BudSearchBar(
                  onTapLeading: () => context.pop(),
                  leadingIcon: AssetsUtil.icon_arrow_back,
                  trailingIcon: AssetsUtil.icon_search,
                  hintText: 'Search summaries',
                  onSubmitted: _onSearchSubmitted,
                ),
              ),
              _onSearch
                  ? Padding(
                      padding: EdgeInsets.only(top: 10.sp),
                      child: DailySearchListView(list: _searchResultLit),
                    )
                  : Padding(
                      padding: EdgeInsets.only(
                        top: 30.sp,
                        left: 20.sp,
                        right: 20.sp,
                      ),
                      child: const JournalHome(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
