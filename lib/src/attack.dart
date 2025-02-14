import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:shieldbound/shieldbound.dart';
import 'package:shieldbound/src/collisions/custom_hitbox.dart';

class Attack extends SpriteComponent
    with HasGameRef<Shieldbound>, TapCallbacks {
  Attack();
  // TODO: Sửa lại attack button cho mobile divces
  final margin = 32; // Đệm nút
  final buttonSize = 100; // Kích thước nút

  // Sprite cho nút tấn công
  late final Sprite attackButton; // Trạng thái mặc định
  late final Sprite attackButtonActive; // Trạng thái được kích hoạt

  // Hitbox cho đòn tấn công
  CustomHitbox atkHitbox = CustomHitbox(
    offset: Vector2.all(5),
    size: Vector2.all(10),
  );
  @override
  FutureOr<void> onLoad() {
    // Thêm nút tấn công cho người chơi trên thiết bị di động
    attackButton = _loadButtonSprite(
        action: 'attack_button'); // Load sprite cho nút ở trạng thái mặc định
    attackButtonActive = _loadButtonSprite(
        action: 'attack_button',
        state: 'active'); // Load sprite cho nút ở trạng thái kích hoạt
    sprite = attackButton; // Trạng thái mặc định
    position = Vector2(
      game.windowWidth - margin - buttonSize,
      game.windowHeight - margin - buttonSize,
    ); // Vị trí của nút
    priority = 10; // Độ ưu tiên (Đặt cao hơn nếu các lớp khác đè lên)
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Xử lý khi nút bấm
    game.player.isAttacking = true;
    sprite = attackButtonActive;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    // Xử lý khi thả nút
    game.player.isAttacking = false;
    sprite = attackButton;
    super.onTapUp(event);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    // Xử lý khi hủy thao tác (Đè và kéo ra ngoài khu vực nút)
    game.player.isAttacking = false;
    sprite = attackButton;
    super.onTapCancel(event);
  }

  Sprite _loadButtonSprite({String? action, String? state}) {
    return (state == null)
        ? Sprite(game.images.fromCache('Hub/$action.png'))
        : Sprite(game.images.fromCache('Hub/${action}_$state.png'));
  }
}
