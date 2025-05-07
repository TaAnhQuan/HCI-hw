import 'package:app/controllers/style_controller.dart';
import 'package:app/extension/datetime_extension.dart';
import 'package:app/extension/media_query_data_extension.dart';
import 'package:app/extension/string_extension.dart';
import 'package:app/services/objectbox_service.dart';
import 'package:app/utils/assets_util.dart';
import 'package:app/views/ui/bud_icon.dart';
import 'package:app/views/ui/bud_search_bar.dart';
import 'package:app/views/ui/bud_text_field.dart';
import 'package:app/views/ui/layout/bud_scaffold.dart';
import 'package:extra_hittest_area/extra_hittest_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/todo_entity.dart';

class TodoModel {
  late int id;
  late bool completed;
  late String title;
  late String? detail;
  late String? deadline;
  late bool stared;

  TodoModel({
    required this.id,
    required this.completed,
    required this.title,
    required this.stared,
    this.deadline,
    this.detail,
  });
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final FocusNode _searchFocusNode = FocusNode();
  List<TodoModel> _list = [];

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initList();
  }

  void _initList() {
    setState(() {
      final results = ObjectBoxService().getAllTodos();
      _list = results?.map((result) => TodoModel(
          id: result.id,
          completed: result.status == Status.completed,
          title: result.task!,
          stared: result.clock,
          deadline: result.deadline == null ? null : DateTime.fromMillisecondsSinceEpoch(result.deadline!).toDateFormatString(showTime: false),
          detail: result.detail,
      )).toList() ?? [];
    });
  }

  void _updateModel() {
    setState(() {});
  }

  void _onClickItem({
    required BuildContext context,
    required TodoModel model,
  }) {
    _searchFocusNode.unfocus();
    showModalBottomSheet(
      context: context,
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.6),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: BottomSheet(
            onClosing: () {},
            builder: (BuildContext context) {
              return TodoDetailSheet(model: model, onUpdate: _updateModel);
            },
          ),
        );
      },
    );
  }

  void _onToggleCompleted(TodoModel model) {
    setState(() {
      model.completed = !model.completed;
    });
    ObjectBoxService().updateTodoStatus(model.id, model.completed ? Status.completed : Status.pending);
  }

  void _onToggleStared(TodoModel model) {
    setState(() {
      model.stared = !model.stared;
    });
    ObjectBoxService().toggleStared(model.id);
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = EdgeInsets.only(
      left: 10.sp,
      right: 10.sp,
    );
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isLightMode = themeNotifier.mode == Mode.light;
    List<TodoModel> todoList = [];
    List<TodoModel> completedList = [];
    for (TodoModel model in _list) {
      model.completed ? completedList.add(model) : todoList.add(model);
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: BudScaffold(
        title: 'to-do list',
        body: Column(
          children: [
            Padding(
              padding: padding.copyWith(bottom: 16.sp),
              child: BudSearchBar(
                focusNode: _searchFocusNode,
                hintText: 'Search to-dos',
                onSubmitted: (String query) {},
              ),
            ),
            Expanded(
              child: ListView(
                padding: padding,
                children: [
                  ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todoList.length,
                    separatorBuilder: (context, index) => SizedBox(height: 8.sp),
                    itemBuilder: (context, index) {
                      TodoModel model = todoList[index];
                      return TodoListTile(
                        onTap: () {
                          _onClickItem(context: context, model: model);
                        },
                        model: model,
                        onToggleCompleted: () {
                          _onToggleCompleted(model);
                        },
                        onToggleStared: () {
                          _onToggleStared(model);
                        },
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 16.sp,
                      bottom: 8.sp,
                    ),
                    child: Text(
                      'Completed',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: isLightMode ? const Color(0xFF1E1B33) : Colors.white,
                      ),
                    ),
                  ),
                  ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: completedList.length,
                    separatorBuilder: (context, index) => SizedBox(height: 8.sp),
                    itemBuilder: (context, index) {
                      TodoModel model = completedList[index];
                      return TodoListTile(
                        onTap: () {
                          _onClickItem(context: context, model: model);
                        },
                        model: model,
                        onToggleCompleted: () {
                          _onToggleCompleted(model);
                        },
                        onToggleStared: () {
                          _onToggleStared(model);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoListTile extends StatelessWidget {
  final TodoModel model;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onToggleCompleted;
  final GestureTapCallback? onToggleStared;

  const TodoListTile({
    super.key,
    required this.model,
    this.onTap,
    this.onToggleCompleted,
    this.onToggleStared
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isLightMode = themeNotifier.mode == Mode.light;
    Color completedColor = isLightMode ? const Color(0xFFF3F3F3) : const Color(0x63242424);
    Color incompleteColor = isLightMode ? const Color(0xFF61D2DB) : const Color(0xFF29BBC6);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.sp,
        vertical: 18.sp,
      ),
      decoration: BoxDecoration(
        color: model.completed ? completedColor : incompleteColor,
        borderRadius: BorderRadius.circular(12.sp),
        boxShadow: [
          if (!model.completed)
            const BoxShadow(
              color: Color.fromRGBO(16, 147, 157, 0.24),
              offset: Offset(0, 5),
              blurRadius: 8,
            ),
        ],
      ),
      child: Row(
        children: [
          GestureDetectorHitTestWithoutSizeLimit(
            debugHitTestAreaColor: Colors.red.withOpacity(0.5),
            extraHitTestArea: EdgeInsets.all(20.sp),
            onTap: onToggleCompleted,
            child: Image.asset(
              AssetsUtil.getIconPath(
                  icon: model.completed
                      ? AssetsUtil.icon_todo_completed
                      : AssetsUtil.icon_todo_incompleted),
              width: 16.sp,
              height: 16.sp,
            ),
          ),
          SizedBox(width: 8.sp),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.sp),
                child: Text(
                  model.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: model.completed ? const Color(0xFF999999) : Colors.white,
                  ),
                ),
              ),
            ),
          ),
          GestureDetectorHitTestWithoutSizeLimit(
            debugHitTestAreaColor: Colors.red.withOpacity(0.5),
            extraHitTestArea: EdgeInsets.all(20.sp),
            onTap: onToggleStared,
            child: Image.asset(
              AssetsUtil.getIconPath(
                  icon: model.stared
                      ? AssetsUtil.icon_todo_star_completed
                      : AssetsUtil.icon_todo_star_incompleted),
              width: 24.sp,
              height: 24.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class TodoDetailSheet extends StatefulWidget {
  final TodoModel model;
  final VoidCallback onUpdate;

  const TodoDetailSheet({
    super.key,
    required this.model,
    required this.onUpdate,
  });

  @override
  State<TodoDetailSheet> createState() => _TodoDetailSheetState();
}

class _TodoDetailSheetState extends State<TodoDetailSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    _titleController.text = widget.model.title;
    _noteController.text = widget.model.detail ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onClickClose() {
    FocusScope.of(context).unfocus();
    context.pop();
  }

  void _onClickCheck() {
    FocusScope.of(context).unfocus();

    setState(() {
      widget.model.title = _titleController.text;
      widget.model.detail = _noteController.text;
    });

    ObjectBoxService().updateTodo(widget.model.id, widget.model.title, widget.model.detail, widget.model.deadline?.toDateTime()?.millisecondsSinceEpoch);

    widget.onUpdate();

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isLightMode = themeNotifier.mode == Mode.light;
    TextStyle textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: isLightMode ? Colors.black : Colors.white,
    );
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: EdgeInsets.only(
          top: 16.sp,
          left: 16.sp,
          right: 16.sp,
          bottom: MediaQuery.of(context).fixedBottom,
        ),
        decoration: BoxDecoration(
          color: isLightMode ? Colors.white : const Color(0xFF333333),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(8.sp),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: _onClickClose,
                  child: BudIcon(
                    icon: AssetsUtil.icon_todo_sheet_close,
                    size: 20.sp,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: _onClickCheck,
                  child: BudIcon(
                    icon: AssetsUtil.icon_todo_sheet_check,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 26.sp),
            Row(
              children: [
                BudIcon(
                  icon: AssetsUtil.icon_todo_sheet_deadline,
                  size: 20.sp,
                ),
                SizedBox(width: 4.sp),
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    maxLines: 1,
                    style: textStyle,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.sp),
            Row(
              children: [
                Text(
                  'deadline',
                  style: textStyle,
                ),
                const Spacer(),
                Text(
                  widget.model.deadline ?? '',
                ),
                SizedBox(width: 12.sp),
                GestureDetector(
                  child: BudIcon(
                    icon: AssetsUtil.icon_arrow_forward_1,
                    size: 14.sp,
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      setState(() {
                        widget.model.deadline = picked.toDateFormatString(showTime: false);
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 12.sp),
            BudTextField(
              height: 136.sp,
              controller: _noteController,
              hintText: 'Please enter a note',
            ),
          ],
        ),
      ),
    );
  }
}