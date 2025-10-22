import 'dart:async';

import 'package:example/components/custom_hitbox.dart';
import 'package:example/example_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum DoorState { opened, closed }

class Door extends SpriteGroupComponent<DoorState>
    with HasGameReference<ExampleGame> {
  Door({required this.leverId, super.position, super.size});

  final hitbox = CustomHitbox(offsetX: 2, offsetY: 2, width: 12, height: 12);
  bool isOpened = false;
  final String? leverId;

  @override
  FutureOr<void> onLoad() {
    priority = 0;

    final tileMap = game.images.fromCache('tilemap_packed.png');
    sprites = {
      DoorState.opened: Sprite(
        tileMap,
        srcPosition: Vector2(144, 0),
        srcSize: Vector2(16, 16),
      ),
      DoorState.closed: Sprite(
        tileMap,
        srcPosition: Vector2(144, 48),
        srcSize: Vector2(16, 16),
      ),
    };

    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive,
      ),
    );

    current = DoorState.closed;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    current = isOpened ? DoorState.opened : DoorState.closed;

    super.update(dt);
  }

  void toggle() {
    isOpened = !isOpened;
  }
}
