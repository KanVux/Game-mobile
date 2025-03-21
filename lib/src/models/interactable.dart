import 'package:flame/components.dart';

/// Lớp cơ sở cho tất cả các đối tượng có thể tương tác (interactable)
/// Bạn có thể mở rộng lớp này để định nghĩa các đối tượng cụ thể, ví dụ: cây, NPC, vật phẩm,...
abstract class Interactable extends SpriteComponent {
  /// Tạo đối tượng Interactable với vị trí, kích thước và điểm neo (anchor) mặc định.
  Interactable({
    required Vector2 position,
    super.size,
    Anchor anchor = Anchor.center,
  }) : super(position: position, anchor: anchor);
}
