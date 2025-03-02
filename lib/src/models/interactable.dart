import 'package:flame/components.dart';
import 'package:flame/events.dart';

/// Lớp cơ sở cho tất cả các đối tượng có thể tương tác (interactable)
/// Bạn có thể mở rộng lớp này để định nghĩa các đối tượng cụ thể, ví dụ: cây, NPC, vật phẩm,...
abstract class Interactable extends SpriteComponent with TapCallbacks {
  /// Tạo đối tượng Interactable với vị trí, kích thước và điểm neo (anchor) mặc định.
  Interactable({
    required Vector2 position,
    Vector2? size,
    Anchor anchor = Anchor.center,
  }) : super(position: position, size: size, anchor: anchor);

  /// Phương thức này sẽ được gọi khi người dùng tương tác (như tap) vào đối tượng.
  /// Các lớp con phải override phương thức này để định nghĩa hành vi tương tác cụ thể.
  void onInteract();

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    onInteract();
  }
}
