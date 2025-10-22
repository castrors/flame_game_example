import 'dart:async';

import 'package:example/components/collision_block.dart';
import 'package:example/components/door.dart';
import 'package:example/components/dungeon_key.dart';
import 'package:example/components/lever.dart';
import 'package:example/components/player.dart';
import 'package:example/components/spider.dart';
import 'package:example/components/trap.dart';
import 'package:example/example_game.dart';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class Level extends World with HasGameReference<ExampleGame> {
  final String levelName;
  final Player player;
  late TiledComponent level;
  List<PositionComponent> collisionBlocks = [];

  Level({required this.levelName, required this.player});
  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(
      levelName,
      Vector2.all(16),
      useAtlas: !kIsWeb,
      layerPaintFactory: (it) => _layerPaint(),
    );
    add(level);

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    for (final spawnPoint in spawnPointsLayer?.objects ?? []) {
      switch (spawnPoint.class_) {
        case 'Player':
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          add(player);
          break;
        case 'DungeonKey':
          final dungeonKey = DungeonKey(
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(16, 16),
          );
          add(dungeonKey);
          break;

        case 'Spider':
          final isVertical =
              spawnPoint.properties.getValue('isVertical') ?? false;
          final offsetNegative =
              spawnPoint.properties.getValue('offsetNegative') ?? 0.0;
          final offsetPositive =
              spawnPoint.properties.getValue('offsetPositive') ?? 0.0;

          final spider = Spider(
            isVertical: isVertical,
            offsetNegative: offsetNegative,
            offsetPositive: offsetPositive,
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(16, 16),
          );
          add(spider);
          break;

        case 'Trap':
          final duration = spawnPoint.properties.getValue('duration') ?? 5.0;
          final trap = Trap(
            duration: duration,
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(16, 16),
          );
          add(trap);
          break;

        case 'Door':
          final leverId = spawnPoint.properties.getValue('lever_id') as String?;
          final door = Door(
            leverId: leverId,
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(16, 16),
          );
          game.doors.add(door);
          add(door);
          break;
        case 'Lever':
          final leverId = spawnPoint.properties.getValue('id') as String?;
          final lever = Lever(
            id: leverId,
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(16, 16),
          );
          add(lever);
          break;
      }
    }

    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    for (final collision in collisionsLayer?.objects ?? []) {
      final block = CollisionBlock(
        position: Vector2(collision.x, collision.y),
        size: Vector2(collision.width, collision.height),
      );
      collisionBlocks.add(block);
      add(block);
    }

    player.collisionBlocks = [...collisionBlocks];
    return super.onLoad();
  }

  Paint _layerPaint() {
    return Paint()
      ..filterQuality = FilterQuality.none
      ..isAntiAlias = false;
  }

  ///https://github.com/flame-engine/flame/issues/1152#issuecomment-2129042281
  /// This is needed to avoid blurry rendering on web
  ///
  /// https://www.verygood.ventures/blog/solving-super-dashs-rendering-challenges-eliminating-ghost-lines-for-a-seamless-gaming-experience
  ///
  ///
}
