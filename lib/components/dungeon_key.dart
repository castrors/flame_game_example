import 'dart:async';

import 'package:example/components/custom_hitbox.dart';
import 'package:example/example_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class DungeonKey extends SpriteComponent with HasGameReference<ExampleGame> {
  DungeonKey({super.position, super.size});

  final hitbox = CustomHitbox(offsetX: 2, offsetY: 2, width: 12, height: 12);

  @override
  FutureOr<void> onLoad() {
    final tileMap = game.images.fromCache('tilemap_packed.png');
    sprite = Sprite(
      tileMap,
      srcPosition: Vector2(112, 128),
      srcSize: Vector2(16, 16),
    );
    add(
      CircleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        radius: hitbox.width / 2,
        collisionType: CollisionType.passive,
      ),
    );
    return super.onLoad();
  }
}
