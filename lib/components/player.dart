import 'dart:async';

import 'package:example/components/collision_block.dart';
import 'package:example/components/door.dart';
import 'package:example/components/dungeon_key.dart';
import 'package:example/components/lever.dart';
import 'package:example/components/spider.dart';
import 'package:example/components/trap.dart';
import 'package:example/example_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

enum PlayerState { idle, runningLeft, runningRight, runningUp, runningDown }

enum PlayerDirection { left, right, up, down, none }

class Player extends SpriteAnimationGroupComponent
    with HasGameReference<ExampleGame>, KeyboardHandler, CollisionCallbacks {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimationDown;
  late final SpriteAnimation runningAnimationUp;
  late final SpriteAnimation runningAnimationLeft;
  late final SpriteAnimation runningAnimationRight;

  Player({super.position});

  PlayerDirection playerDirection = PlayerDirection.none;
  double moveSpeed = 100;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  bool isFacingRight = true;
  List<PositionComponent> collisionBlocks = [];
  double horizontalMovement = 0;
  double verticalMovement = 0;

  Set<Lever> collidingLevers = <Lever>{};

  @override
  FutureOr<void> onLoad() {
    priority = 1;
    _loadAllAnimations();

    startingPosition = Vector2(position.x, position.y);

    add(
      CircleHitbox(
        position: Vector2(2, 2),
        radius: size.x * 0.4,
        collisionType: CollisionType.active,
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    // _checkCollisions();
    super.update(dt);
  }

  // @override
  // void onCollisionStart(
  //   Set<Vector2> intersectionPoints,
  //   PositionComponent other,
  // ) {
  //   super.onCollisionStart(intersectionPoints, other);

  //   if (other is CollisionBlock) {
  //     // Calculate the collision normal and separation distance.
  //     final mid =
  //         (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) /
  //         2;

  //     final collisionNormal = absoluteCenter - mid;
  //     final separationDistance = (hitbox.size.x / 2) - collisionNormal.length;
  //     collisionNormal.normalize();

  //     // Resolve collision by moving ember along
  //     // collision normal by separation distance.
  //     position += collisionNormal.scaled(separationDistance);
  //   }
  // }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is CollisionBlock) {
      // Calculate the collision normal and separation distance.
      if (intersectionPoints.length < 2) {
        return;
      }
      final mid =
          (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) /
          2;

      final collisionNormal = absoluteCenter - mid;
      final separationDistance = (size.x / 2) - collisionNormal.length;
      collisionNormal.normalize();

      // Resolve collision by moving ember along
      // collision normal by separation distance.
      position += collisionNormal.scaled(separationDistance);
    }
    if (other is Lever) {
      final lever = other;
      // Only toggle if this lever hasn't been collided with yet
      if (!collidingLevers.contains(lever)) {
        collidingLevers.add(lever);
        lever.toggle();
        print('Lever ${lever.id} toggled. New state: ${lever.isActive}');
      }
    }

    if (other is Door) {
      final door = other;
      if (door.isOpened) {
        _reachedCheckpoint();
        return;
      }
    }
    if (other is DungeonKey) {
      other.removeFromParent();
      game.keysCollected += 1;
      print('Keys collected: ${game.keysCollected}');
    }
    if (other is Trap) {
      final trap = other;
      if (trap.isActive) {
        _respawn();
        print('Player hit a trap! Resetting position.');
      }
    }
    if (other is Spider) {
      _respawn();
      print('Player hit a spider! Resetting position.');
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is Lever) {
      // Remove the lever from the colliding set when collision ends
      collidingLevers.remove(other);
    }
    super.onCollisionEnd(other);
  }

  // void _checkCollisions() {
  //   for (final block in collisionBlocks) {
  //     if (checkCollision(this, block)) {
  //       if (velocity.x > 0) {
  //         velocity.x = 0;
  //         position.x = block.x - width;
  //         break;
  //       }
  //       if (velocity.x < 0) {
  //         velocity.x = 0;
  //         position.x = block.x + block.width + width;
  //         break;
  //       }
  //     }
  //   }
  // }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x > 0) playerState = PlayerState.runningRight;
    if (velocity.x < 0) playerState = PlayerState.runningLeft;
    if (velocity.y > 0) playerState = PlayerState.runningDown;
    if (velocity.y < 0) playerState = PlayerState.runningUp;

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;

    velocity.y = verticalMovement * moveSpeed;
    position.y += velocity.y * dt;
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation(row: 0, stepTime: 0.5, from: 0, to: 2);
    runningAnimationDown = _spriteAnimation(row: 0, from: 0, to: 4);
    runningAnimationUp = _spriteAnimation(row: 1, from: 0, to: 4);
    runningAnimationLeft = _spriteAnimation(row: 2, from: 0, to: 4);
    runningAnimationRight = _spriteAnimation(row: 3, from: 0, to: 4);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.runningLeft: runningAnimationLeft,
      PlayerState.runningRight: runningAnimationRight,
      PlayerState.runningUp: runningAnimationUp,
      PlayerState.runningDown: runningAnimationDown,
    };
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation({
    required int row,
    required int from,
    required int to,
    double stepTime = 0.1,
  }) {
    final spriteSheet = SpriteSheet(
      image: game.images.fromCache('player_trimmed.png'),
      srcSize: Vector2(16, 16),
    );
    return spriteSheet.createAnimation(
      row: row,
      stepTime: stepTime,
      from: from,
      to: to,
    );
  }

  void _respawn() {
    position = startingPosition;
  }

  void _reachedCheckpoint() {
    position = Vector2.all(-640);
    const waitToChangeDuration = Duration(seconds: 1);
    Future.delayed(waitToChangeDuration, () {
      game.loadNextLevel();
    });
  }
}
