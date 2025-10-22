import 'dart:async';

import 'package:example/components/door.dart';
import 'package:example/components/player.dart';
import 'package:example/components/level.dart';
import 'package:flame/components.dart';
// import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter/painting.dart';

class ExampleGame extends FlameGame with KeyboardEvents, HasCollisionDetection
// , DragCallbacks
{
  late CameraComponent cameraComponent;
  Player player = Player();
  late JoystickComponent joystick;
  List<String> levelNames = ['level-01.tmx', 'level-01.tmx'];
  int currentLevelIndex = 0;
  Set<Door> doors = {};

  int keysCollected = 0;

  @override
  FutureOr<void> onLoad() async {
    // debugMode = true;
    await images.loadAllImages();

    _loadLevel();
    // addJoystick();

    return super.onLoad();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      player.horizontalMovement = -1;
    } else if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      player.horizontalMovement = 1;
    } else if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      player.verticalMovement = -1;
    } else if (keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      player.verticalMovement = 1;
    } else {
      player.horizontalMovement = 0;
      player.verticalMovement = 0;
    }

    return KeyEventResult.handled;
  }

  // Add this method to your ExampleGame class
  void toggleDoor(String? leverId) {
    if (leverId == null) return;

    // Find the door with matching leverId and toggle it
    for (final door in doors) {
      if (door.leverId == leverId) {
        door.toggle();
        break;
      }
    }
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);
    doors.clear();
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      // no more levels
    }
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 2), () {
      Level world = Level(
        levelName: levelNames[currentLevelIndex],
        player: player,
      );

      cameraComponent = CameraComponent.withFixedResolution(
        world: world,
        width: 480,
        height: 320,
      );
      cameraComponent.viewfinder.anchor = Anchor.topLeft;

      addAll([cameraComponent, world]);
    });
  }

  // @override
  // void update(double dt) {
  //   updateJoystick();
  //   super.update(dt);
  // }

  // void addJoystick() {
  //   joystick = JoystickComponent(
  //     priority: 10,
  //     knob: CircleComponent(
  //       radius: 15,
  //       paint: Paint()..color = const Color(0xFF00FF00),
  //     ),
  //     background: CircleComponent(
  //       radius: 50,
  //       paint: Paint()..color = const Color(0x7700FF00),
  //     ),
  //     margin: const EdgeInsets.only(left: 32, bottom: 32),
  //   );
  //   add(joystick);
  // }

  // void updateJoystick() {
  //   switch (joystick.direction) {
  //     case JoystickDirection.left:
  //       player.playerDirection = PlayerDirection.left;
  //       break;
  //     case JoystickDirection.right:
  //       player.playerDirection = PlayerDirection.right;
  //       break;
  //     case JoystickDirection.up:
  //       player.playerDirection = PlayerDirection.up;
  //       break;
  //     case JoystickDirection.down:
  //       player.playerDirection = PlayerDirection.down;
  //       break;
  //     case JoystickDirection.upLeft:
  //       if (player.playerDirection != PlayerDirection.left) {
  //         player.playerDirection = PlayerDirection.up;
  //       } else {
  //         player.playerDirection = PlayerDirection.left;
  //       }
  //       break;
  //     case JoystickDirection.upRight:
  //       if (player.playerDirection != PlayerDirection.right) {
  //         player.playerDirection = PlayerDirection.up;
  //       } else {
  //         player.playerDirection = PlayerDirection.right;
  //       }
  //       break;
  //     case JoystickDirection.downLeft:
  //       if (player.playerDirection != PlayerDirection.left) {
  //         player.playerDirection = PlayerDirection.down;
  //       } else {
  //         player.playerDirection = PlayerDirection.left;
  //       }
  //       break;
  //     case JoystickDirection.downRight:
  //       if (player.playerDirection != PlayerDirection.right) {
  //         player.playerDirection = PlayerDirection.down;
  //       } else {
  //         player.playerDirection = PlayerDirection.right;
  //       }
  //       break;
  //     case JoystickDirection.idle:
  //       player.playerDirection = PlayerDirection.none;
  //       break;
  //   }
  // }
}
