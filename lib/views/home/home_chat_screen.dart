import 'package:app/controllers/style_controller.dart';
import 'package:app/extension/media_query_data_extension.dart';
import 'package:app/utils/route_utils.dart';
import 'package:app/views/components/chat_list_tile.dart';
import 'package:app/views/components/home_app_bar.dart';
import 'package:app/views/components/home_bottom_bar.dart';
import 'package:app/views/ui/app_backgroud.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../constants/prompt_constants.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/record_controller.dart';

class HomeChatScreen extends StatefulWidget {
  final RecordScreenController? controller;

  const HomeChatScreen({super.key, this.controller});

  @override
  State<HomeChatScreen> createState() => _HomeChatScreenState();
}

class _HomeChatScreenState extends State<HomeChatScreen> {
  late ChatController _chatController;
  final FocusNode _focusNode = FocusNode();
  late RecordScreenController _audioController;

  final _listenable = IndicatorStateListenable();
  bool _shrinkWrap = false;
  double? _viewportDimension;
  bool _bluetoothConnected = false;

  final TextStyle textTextStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  final EdgeInsets chatPadding =
      EdgeInsets.symmetric(horizontal: 18.sp, vertical: 12.sp);

  final double lineSpace = 16.sp;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _chatController.dispose();
    _listenable.removeListener(_onHeaderChange);
    super.dispose();
  }

  void _init() {
    if (widget.controller == null) {
      _audioController = RecordScreenController();
      _audioController.load();
    } else {
      _audioController = widget.controller!;
    }
    _audioController.attach(this);
    _listenable.addListener(_onHeaderChange);
    _chatController = ChatController(
      onNewMessage: onNewMessage,
    );
  }

  void _onHeaderChange() {
    final state = _listenable.value;
    if (state != null) {
      final position = state.notifier.position;
      _viewportDimension ??= position.viewportDimension;
      final shrinkWrap = state.notifier.position.maxScrollExtent == 0;
      if (_shrinkWrap != shrinkWrap &&
          _viewportDimension == position.viewportDimension) {
        setState(() {
          _shrinkWrap = shrinkWrap;
        });
      }
    }
  }

  void onNewMessage() {
    if (mounted) {
      setState(() {});
    }
  }

  double _calculateMsgHeight(
    BuildContext context,
    BoxConstraints constraints,
    String text,
  ) {
    BoxConstraints textConstraints = constraints.copyWith(
      maxWidth: constraints.maxWidth -
          ChatListTile.textWidthSpace -
          chatPadding.horizontal,
    );
    double textHeight = _calculateTextHeight(
      context,
      textConstraints,
      text: text,
      textStyle: textTextStyle,
    );

    double initH = 2 + chatPadding.vertical + textHeight + lineSpace;
    return initH;
  }

  double _calculateTextHeight(
    BuildContext context,
    BoxConstraints constraints, {
    String text = '',
    required TextStyle textStyle,
    List<InlineSpan> children = const [],
  }) {
    final span = TextSpan(text: text, style: textStyle, children: children);

    final richTextWidget = Text.rich(span).build(context) as RichText;
    final renderObject = richTextWidget.createRenderObject(context);
    renderObject.layout(constraints);
    double height =
        renderObject.computeMinIntrinsicHeight(constraints.maxWidth);
    return height;
  }

  Widget _buildMsg(Map<String, dynamic> message) {
    final role = message['isUser'];
    final text = message['text'];
    return Padding(
      padding: EdgeInsets.only(bottom: lineSpace),
      child: ChatListTile(
        onLongPress: () => _chatController.copyToClipboard(context, text),
        role: role,
        text: text,
        style: textTextStyle,
        padding: chatPadding,
      ),
    );
  }

  void _onClickKeyboard() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    } else {
      _focusNode.requestFocus();
    }
  }

  void _onClickBluetooth() {
    setState(() {
      _bluetoothConnected = !_bluetoothConnected;
    });
  }

  void _onClickRecord() {
    setState(() {
      _audioController.toggleRecording();
    });
  }

  void _onClickSendMessage() {
    _chatController.sendMessage();
  }

  void _onClickHelp() {
    _chatController.sendMessage(initialText: systemPromptOfHelp);
  }

  void _onClickBottomRight() {
    _focusNode.unfocus();
    context.pushNamed(RouteName.journal);
  }

  bool _checkMessageOverflowScreen(BoxConstraints constraints) {
    bool overflow = false;
    double heightTmp = 0.0;
    for (int i = 0; i < _chatController.messages.length; i++) {
      final text = _chatController.messages[i]['text'];
      var hi = _calculateMsgHeight(context, constraints, text);
      heightTmp += hi;
      if (heightTmp >= constraints.maxHeight) {
        overflow = true;
        break;
      }
    }
    return overflow;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AppBackground(
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 10.sp,
              right: 10.sp,
              bottom: MediaQuery.of(context).fixedBottom,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.sp),
                  child: HomeAppBar(
                    bluetoothConnected: _audioController.connectionState,
                    onTapBluetooth: _onClickBluetooth,
                  ),
                ),
                SizedBox(height: 18.sp),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: 8.sp,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final overflow =
                            _checkMessageOverflowScreen(constraints);

                        final messageList = _chatController.messages;

                        return EasyRefresh(
                          header: const MaterialHeader(triggerOffset: 30.0),
                          footer: const MaterialFooter(triggerOffset: 30.0),
                          clipBehavior: Clip.none,
                          key: ValueKey(_chatController.refreshCount),
                          onLoad: overflow
                              ? () async {
                                  return _chatController.loadMoreMessages();
                                }
                              : null,
                          child: ClipRect(
                            child: CustomScrollView(
                              controller: _chatController.scrollController,
                              reverse: true,
                              shrinkWrap: !overflow,
                              clipBehavior: Clip.none,
                              slivers: [
                                overflow
                                    ? SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          (BuildContext context, int i){
                                            if(i>=messageList.length){
                                              return SizedBox();
                                            }
                                            return  _buildMsg(messageList[i]);
                                            },
                                          childCount: messageList.length,
                                        ),
                                      )
                                    : SliverToBoxAdapter(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: messageList
                                                .map((e) => _buildMsg(e))
                                                .toList()
                                                .reversed
                                                .toList(),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                HomeBottomBar(
                  controller: _chatController.textController,
                  onTapKeyboard: _onClickKeyboard,
                  onSubmitted: (_) {},
                  onTapSend: _onClickSendMessage,
                  onTapLeft: _onClickRecord,
                  onTapHelp: _onClickHelp,
                  onTapRight: _onClickBottomRight,
                  isRecording: _audioController.isRecording,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
