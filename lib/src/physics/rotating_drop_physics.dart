import 'dart:math';
import 'package:simple_3d/simple_3d.dart';

///
/// (en) This is a class for physics calculations
/// that can simulate the movement of falling while rotating on a plane.
///
/// (ja) 平面的に回転しながら落下する動きをシミュレート可能な、物理演算のためのクラスです。
///
/// Author Masahide Mori
///
class RotatingDropPhysics extends Sp3dPhysics {
  /// 回転関連パラメータ
  late final double rotationDirection;
  late final double rotationSpeed;

  /// fpsによらず速度を一定にするためのパラメータ
  final int fps;

  /// * [rotationSpeed] : The object rotation speed.
  /// * [rotationDirection] : Specifies whether to rotate
  /// the object counterclockwise or clockwise, as 1 or -1.
  /// If not specified, a random value will be set.
  /// * [fps] : The screen fps.
  RotatingDropPhysics(
      {double? rotationSpeed, double? rotationDirection, this.fps = 60}) {
    this.rotationSpeed = rotationSpeed ?? Random().nextDouble() / 10 + 0.01;
    this.rotationDirection =
        rotationDirection ?? (Random().nextBool() ? 1.0 : -1.0);
  }

  /// object speed.
  @override
  double? get speed {
    return 60 / fps;
  }

  /// object motion velocity.
  @override
  Sp3dV3D? get velocity {
    return Sp3dV3D(0, -1, 0) * speed!;
  }

  /// object rotation axis.
  @override
  Sp3dV3D? get rotateAxis {
    return Sp3dV3D(0, 0, -1);
  }

  /// object rotation parameter.
  @override
  double? get angularVelocity => rotationDirection * rotationSpeed * speed!;
}
