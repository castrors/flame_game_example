import 'dart:async';

import 'package:example/components/custom_hitbox.dart';
import 'package:example/example_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

enum TrapState { on, off }

class Trap extends SpriteGroupComponent<TrapState>
    with HasGameReference<ExampleGame> {
  Trap({required this.duration, super.position, super.size});

  final hitbox = CustomHitbox(offsetX: 2, offsetY: 2, width: 12, height: 12);
  bool isActive = true;
  double _timer = 0.0;
  final double duration;

  @override
  FutureOr<void> onLoad() {
    final tileMap = game.images.fromCache('tilemap_packed.png');
    sprites = {
      TrapState.on: Sprite(
        tileMap,
        srcPosition: Vector2(80, 128),
        srcSize: Vector2(16, 16),
      ),
      TrapState.off: Sprite(
        tileMap,
        srcPosition: Vector2(96, 128),
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

    current = TrapState.on;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // Accumulate time
    _timer += dt;

    // Toggle every five second
    if (_timer >= duration) {
      isActive = !isActive;
      if (game.playSounds) {
        FlameAudio.play('trapMovement.wav', volume: game.soundVolume);
      }
      _timer = 0.0; // Reset timer
    }

    // Update current state based on isActive
    current = isActive ? TrapState.on : TrapState.off;

    super.update(dt);
  }
}
