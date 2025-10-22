import 'dart:async';

import 'package:example/components/custom_hitbox.dart';
import 'package:example/example_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum LeverState { opened, closed }

class Lever extends SpriteGroupComponent<LeverState>
    with HasGameReference<ExampleGame> {
  Lever({required this.id, super.position, super.size});

  final hitbox = CustomHitbox(offsetX: 2, offsetY: 2, width: 12, height: 12);
  bool isActive = true;

  final String? id;

  @override
  FutureOr<void> onLoad() {
    priority = 0;

    final tileMap = game.images.fromCache('tilemap_packed.png');
    sprites = {
      LeverState.opened: Sprite(
        tileMap,
        srcPosition: Vector2(80, 144),
        srcSize: Vector2(16, 16),
      ),
      LeverState.closed: Sprite(
        tileMap,
        srcPosition: Vector2(96, 144),
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

    current = LeverState.closed;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    current = isActive ? LeverState.opened : LeverState.closed;

    super.update(dt);
  }

  void toggle() {
    isActive = !isActive;
    game.toggleDoor(id);
  }
}
