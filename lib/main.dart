import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shieldbound/src/ui/menu/main_menu.dart';

import 'src/services/pocketbase_service.dart';

bool isDebugModeActivated = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  // Kiểm tra kết nối PocketBase
  final pocketbaseService = PocketBaseService();
  await pocketbaseService.initialize();
  await pocketbaseService.logConnectionTest();

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShieldBound RPG',
      home: MainMenu(), // Start with the Main Menu
    );
  }
}
