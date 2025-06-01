import 'dart:io';
import 'package:app/extension/media_query_data_extension.dart';
import 'package:app/utils/route_utils.dart';
import 'package:app/views/components/chat_list_tile.dart';
import 'package:app/views/components/home_app_bar.dart';
import 'package:app/views/components/home_bottom_bar.dart';
import 'package:app/views/ui/app_background.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/record_controller.dart';
import '../../utils/assets_util.dart';

class HomeChatScreen extends StatefulWidget {
  final RecordScreenController? controller;

  const HomeChatScreen({super.key, this.controller});

  @override
  State<HomeChatScreen> createState() => _HomeChatScreenState();
}

class _HomeChatScreenState extends State<HomeChatScreen>
    with WidgetsBindingObserver {
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

  List<BluetoothDevice> pairedDevices = [];
  bool _paired = false;
  bool _isBottomSheetShown = false;

  @override
  void initState() {
    super.initState();
    _init();
    // Register this class as an observer to listen for keyboard changes
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentBottomInset = MediaQuery.of(context).viewInsets.bottom;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    _chatController.dispose();
    _listenable.removeListener(_onHeaderChange);
    super.dispose();
  }

  double currentBottomInset = 0;

  @override
  void didChangeMetrics() {
    // This is called when the metrics change (including keyboard visibility)
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final diff = bottomInset - currentBottomInset;
    currentBottomInset = bottomInset;
    double jumpOffset = _chatController.scrollController.offset + diff;

    if (jumpOffset >= 0 &&
        jumpOffset <=
            _chatController.scrollController.position.maxScrollExtent) {
      _chatController.scrollController.jumpTo(jumpOffset);
    }
  }

  Future<void> _getPairedDevices() async {
    if (Platform.isIOS) {
      // pairedDevices = await FlutterBluePlus.systemDevices([]);
      // if (pairedDevices.isEmpty) {
      //   pairedDevices = await FlutterBluePlus.bondedDevices;
      // }
      _paired = true;
    } else if (Platform.isAndroid) {
      bool found = false;
      try {
        pairedDevices = await FlutterBluePlus.bondedDevices;
      } catch (e) {
        debugPrint('Cannot find bounded devices: $e');
        _paired = true;
        return;
      }


      for (final pairedDevice in pairedDevices) {
        if (pairedDevice.platformName.startsWith("Buddie")) {
          found = true;
          break;
        }
      }

      _paired = found;
    }
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool("isFirstLaunch") ?? true;
      if (isFirstLaunch) {
        await prefs.setBool("isFirstLaunch", false);
        debugPrint('init recording');
      } else {
        debugPrint('start recording');
      }
      FlutterForegroundTask.sendDataToTask('startRecording');
    });
  }

  // void _showEarphoneConnectDialog() async {
  //   bool? connect = await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const EarphoneDialog(),
  //         actions: [
  //           TextButton(
  //             onPressed: () => context.pop(false),
  //             child: const Text('cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () => context.pop(true),
  //             child: const Text('connect'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //   if (connect == true) {
  //     showDialog(
  //       context: context,
  //       builder: (context) {
  //         // return BLEScreen();
  //       },
  //     );
  //   }
  // }

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

  Widget _buildMsg(Map<String, dynamic> message) {
    final role = message['isUser'];
    final text = message['text'];
    final id = message['id'];
    Widget body = Padding(
      padding: EdgeInsets.only(bottom: lineSpace),
      child: ChatListTile(
        onLongPress: () => _chatController.copyToClipboard(context, text),
        role: role,
        text: text,
        style: textTextStyle,
        padding: chatPadding,
      ),
    );

    if (_chatController.unReadMessageId.value.contains(id)) {
      body = VisibilityDetector(
        key: UniqueKey(),
        onVisibilityChanged: (info) {
          if (info.visibleFraction == 1) {
            _chatController.unReadMessageId.value.remove(id);
            _chatController.unReadMessageId.notifyListeners();
          }
        },
        child: body,
      );
    }

    return body;
  }

  void _onClickKeyboard() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    } else {
      _focusNode.requestFocus();
    }
  }

  void _onClickBluetooth() async {
  }

  void _onClickRecord() {
    setState(() {
      _audioController.toggleRecording();
    });
  }

  void _onClickSendMessage() {
    _chatController.sendMessage();
  }

  void _onClickTool(){

  }

  void _onClickHelp() {
    _chatController.askHelp();
  }

  void _onClickBottomRight() {
    _focusNode.unfocus();
    context.pushNamed(RouteName.meeting_list);
    // context.pushNamed(RouteName.journal);
  }

  var centerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final slivers = <Widget>[];
    final history = _chatController.historyMessages.reversed.toList();
    slivers.add(SliverList(
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int i) {
          if (i > history.length) {
            return SizedBox();
          }
          return _buildMsg(history[i]);
        },
        childCount: history.length,
      ),
    ));

    slivers.add(SliverPadding(
      padding: EdgeInsets.zero,
      key: centerKey,
    ));
    final newMessage = _chatController.newMessages.reversed.toList();
    slivers.add(SliverList(
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int i) {
          if (i > newMessage.length) {
            return SizedBox();
          }
          return _buildMsg(newMessage[i]);
        },
        childCount: newMessage.length,
      ),
    ));
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
                    child: Stack(
                      children: [
                        RefreshIndicator(
                            displacement: 10,
                            onRefresh: _chatController.loadMoreMessages,
                            child: ClipRect(
                              child: CustomScrollView(
                                controller: _chatController.scrollController,
                                clipBehavior: Clip.none,
                                center: centerKey,
                                cacheExtent: 3,
                                slivers: slivers,
                              ),
                            )),
                        Align(
                          alignment: AlignmentDirectional.bottomEnd,
                          child: ValueListenableBuilder(
                              valueListenable: _chatController.unReadMessageId,
                              builder: (context, ids, _) {
                                if (ids.isEmpty) return const SizedBox();
                                return GestureDetector(
                                  onTap: () {
                                    _chatController.unReadMessageId.value = {};
                                    _chatController.firstScrollToBottom();
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: Colors.blue),
                                    child: Center(
                                      child: Text(
                                        ids.length.toString(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        )
                      ],
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
                  isSpeakValueNotifier: _chatController.isSpeakValueNotifier,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EarphoneDialog extends StatelessWidget {
  final GestureTapCallback? onClickConnect;

  const EarphoneDialog({
    super.key,
    this.onClickConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AssetsUtil.logo_hd,
          width: 116.sp,
          height: 116.sp,
        ),
      ],
    );
  }
}
