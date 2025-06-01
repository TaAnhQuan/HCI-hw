import 'dart:developer';
import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../services/asr_service.dart';
import '../views/voiceprint_screen.dart';


class RecordScreenController {
  State? _state;

  String transcriptionStatus = '';

  bool isRecording = true;
  String? deviceRemoteId;
  String? deviceName;
  BluetoothConnectionState connectionState = BluetoothConnectionState.disconnected;

  Future<void> load() async {
    if (!await FlutterForegroundTask.isRunningService) {
      await _initService();
      await startService();
      await Future.delayed(Duration(seconds: 1));
    }
  }

  @mustCallSuper
  void attach(State state) {  
    _state = state;
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    // BleService().init(isUI: true).then((_) {
    //   // _getDeviceInfo();
    //   // scanAndConnect();
    // });
  }

  @mustCallSuper
  void detach() {
    _state = null;
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
  }

  @mustCallSuper
  void dispose() {
    detach();
  }

  void toggleRecording() {
    isRecording = !isRecording;
    if (isRecording) {
      FlutterForegroundTask.sendDataToTask("startRecording");
    } else {
      FlutterForegroundTask.sendDataToTask("stopRecording");
    }
  }

  Future<void> _initService() async {
    await _requestPlatformPermissions();

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'buddie_service',
        channelName: 'Buddie Service',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(3 * 60 * 1000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<void> startService() async {
    await _requestRecordPermission();
    await _requestBlePermissions();
    final ServiceRequestResult result = await FlutterForegroundTask.startService(
      serviceId: 300,
      notificationTitle: 'Buddie Service',
      notificationText: 'Tap to return to the app',
      callback: startRecordService,
    );

    // if (!result.success) {
    //   throw result.error ?? Exception('An error occurred and the service could not be started.');
    // }
  }

  Future<void> stopService() async {
    if (!await FlutterForegroundTask.isRunningService) {
      return;
    }

    final ServiceRequestResult result = await FlutterForegroundTask.stopService();

    // if (!result.success) {
    //   throw result.error ?? Exception('An error occurred and the service could not be stopped.');
    // }
  }

  void _onReceiveTaskData(Object data) {
    // debugPrint(data.toString());

    if (data is Map<String, dynamic>) {
      final action = data['action'] as String?;
      final connection = data['connectionState'] as bool?;
      final devName = data['deviceName'] as String?;
      final devId = data['deviceId'] as String?;
      final recording = data['isRecording'] as bool?;

      if (recording == true) {
        _state?.setState(() {
          isRecording = true;
        });
      }

      if (action == 'deviceReset') {
        _state?.setState(() {
          deviceRemoteId = null;
          deviceName = null;
          connectionState = BluetoothConnectionState.disconnected;
        });
      }

      if (connection == true) {
        _state?.setState(() {
          connectionState = BluetoothConnectionState.connected;
          deviceName = devName;
          deviceRemoteId = devId;
        });
      } else if(connection == false) {
        _state?.setState(() {
          connectionState = BluetoothConnectionState.disconnected;
          deviceName = devName;
          deviceRemoteId = devId;
        });
      }
    }
  }

  Future<void> _requestPlatformPermissions() async {
    // final NotificationPermission notificationPermission =
    //   await FlutterForegroundTask.checkNotificationPermission();
    // if (notificationPermission != NotificationPermission.granted) {
    //   await FlutterForegroundTask.requestNotificationPermission();
    // }

    if (Platform.isAndroid) {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    }
  }

  Future<void> _requestRecordPermission() async {
    if (!await AudioRecorder().hasPermission()) {
      throw Exception('To start record service, you must grant microphone permission.');
    }
  }

  Future<void> _requestBlePermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
      ].request();
      // Android 11 
      // if (await Permission.locationWhenInUse.isDenied) {
      //   await Permission.locationWhenInUse.request();
      // }
    } else if (Platform.isIOS) {
      if (await Permission.bluetooth.isDenied) {
        await Permission.bluetooth.request();
      }
    }
  }

  // void _getDeviceInfo() async {
  //   deviceRemoteId = BleService().deviceRemoteId;
  //   deviceName = BleService().deviceName;
  //   if (deviceRemoteId != null) {
  //     connectionState = BleService().connectionState;
  //     BleService().connectionStateStream.listen((state) {
  //       _state?.setState(() {
  //         connectionState = state;
  //       });
  //     });
  //   }
  // }
  //
  // Future<void> scanAndConnect() async {
  //   Timer.periodic(Duration(minutes: 1), (timer) async {
  //     if (deviceRemoteId == null) {
  //       final success = await BleService().scanAndConnect();
  //       if (success) {
  //         _getDeviceInfo();
  //         _state?.setState(() {});
  //         FlutterForegroundTask.sendDataToTask("initBle");
  //         timer.cancel();
  //       }
  //     } else {
  //       timer.cancel();
  //     }
  //   });
  // }
}
