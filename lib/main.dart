import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:shieldbound/src/ui/menu/main_menu.dart';

bool isDebugModeActived = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShieldBound RPG',
      home: MainMenu(), // Start with the Main Menu
    );
  }
}
