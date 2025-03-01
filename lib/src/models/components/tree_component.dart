import 'dart:async';
import 'package:flame/components.dart';
import 'package:shieldbound/main.dart';
import 'package:shieldbound/src/models/interactable.dart';

class TreeComponent extends Interactable {
  TreeComponent({required Vector2 position})
      : super(
          position: position,
          size: Vector2(150, 150), // Điều chỉnh kích thước theo ảnh của bạn
          anchor: Anchor.bottomCenter, // Để sắp xếp chiều sâu chính xác
        );

  @override
  FutureOr<void> onLoad() async {
    debugMode = isDebugModeActived;
    sprite = await Sprite.load('Resources/Trees/Tree.png');
    return super.onLoad();
  }

  @override
  void onInteract() {
    // Định nghĩa hành vi khi người dùng tương tác với cây, ví dụ: in ra log hoặc kích hoạt animation
    print('Cây tại vị trí $position được tương tác.');
  }
}
