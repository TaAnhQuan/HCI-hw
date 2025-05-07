import 'package:app/controllers/auth_controller.dart';
import 'package:app/controllers/style_controller.dart';
import 'package:app/services/objectbox_service.dart';
import 'package:app/utils/route_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/user_model_controller.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  // Initialize port for communication between TaskHandler and UI.
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  FlutterForegroundTask.initCommunicationPort();

  await ObjectBoxService.initialize();

  FlutterBluePlus.setLogLevel(LogLevel.error);
  FlutterBluePlus.setOptions(restoreState: true);

  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool("isFirstLaunch") ?? true;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authController = Get.put(MyAuthController());
  await authController.signInAnonymously();
  final token = await authController.fetchLlmToken();
  FlutterForegroundTask.saveData(key: 'llmToken', value: token);

  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://476fe26ce43858184b0f5309106671d6@o4507015727874048.ingest.us.sentry.io/4508811095375872';
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
      options.diagnosticLevel = SentryLevel.warning;
    },
    appRunner: () => runApp(
      SentryWidget(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeNotifier()),
            ChangeNotifierProvider(create: (_) => UserModelController()),
          ],
          child: MyApp(isFirstLaunch: isFirstLaunch),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;

  const MyApp({required this.isFirstLaunch, super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: MaterialApp.router(
        title: 'Bud',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00B2CA)),
          useMaterial3: true,
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
            displaySmall: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: GoRouter(
          initialLocation: RouteName.loading,
          observers: [BudNavigatorObserver()],
          routes: RouteUtils.routes,
        ),
      ),
    );
  }
}