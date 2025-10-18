import 'dart:async';

import 'package:example/components/custom_hitbox.dart';
import 'package:example/example_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Spider extends SpriteComponent with HasGameReference<ExampleGame> {
  Spider({
    required this.isVertical,
    required this.offsetNegative,
    required this.offsetPositive,
    super.position,
    super.size,
  });

  final hitbox = CustomHitbox(offsetX: 2, offsetY: 2, width: 12, height: 12);
  final bool isVertical;
  final double offsetNegative;
  final double offsetPositive;
  static const double moveSpeed = 20.0;
  static const double tileSize = 16.0;
  double moveDirection = 1;
  double rangeNegative = 0.0;
  double rangePositive = 0.0;

  @override
  FutureOr<void> onLoad() {
    if (isVertical) {
      rangeNegative = position.y - (offsetNegative * tileSize);
      rangePositive = position.y + (offsetPositive * tileSize);
    } else {
      rangeNegative = position.x - (offsetNegative * tileSize);
      rangePositive = position.x + (offsetPositive * tileSize);
    }

    final tileMap = game.images.fromCache('tilemap_packed.png');
    sprite = Sprite(
      tileMap,
      srcPosition: Vector2(32, 160),
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

  @override
  void update(double dt) {
    if (isVertical) {
      _moveVertically(dt);
    } else {
      _moveHorizontally(dt);
    }
    super.update(dt);
  }

  void _moveVertically(double dt) {
    position.y += moveDirection * moveSpeed * dt;

    if (position.y <= rangeNegative) {
      position.y = rangeNegative;
      moveDirection = 1;
    } else if (position.y >= rangePositive) {
      position.y = rangePositive;
      moveDirection = -1;
    }
  }

  void _moveHorizontally(double dt) {
    position.x += moveDirection * moveSpeed * dt;

    if (position.x <= rangeNegative) {
      position.x = rangeNegative;
      moveDirection = 1;
    } else if (position.x >= rangePositive) {
      position.x = rangePositive;
      moveDirection = -1;
    }
  }
}
