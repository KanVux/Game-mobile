import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shieldbound/shieldbound.dart';

bool isDebugModeActived = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  Shieldbound game = Shieldbound();
  runApp(GameWidget(game: kDebugMode ? Shieldbound() : game));
}
