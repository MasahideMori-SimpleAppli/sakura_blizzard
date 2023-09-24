import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';

///
/// (en) A class for physics calculations
/// that can simulate the falling motion of cherry blossom petals.
///
/// (ja) 桜の花びらの落下する動きをシミュレート可能な、物理演算のためのクラスです。
///
/// Author Masahide Mori
///
class HirahiraDropPhysics extends Sp3dPhysics {
  /// 花びらが落ちるアニメーションの調整用カウンタ。
  double _nowPoint = 0;

  /// 落下速度
  final double baseFallSpeed;
  late final double _fallSpeed;

  /// シフト関係パラメータ
  /// 最初のシフト方向。1なら右シフト、-1なら左シフトする。
  final int _lrMovement = Random().nextBool() ? 1 : -1;

  /// 画面の何分の一を基準に左右に揺れるかという指定。
  final double _shiftValue = Random().nextDouble() * 1.5 + 1.5;

  /// 親ビューのサイズ情報
  final Size size;

  /// 回転関連パラメータ
  late final double rotationSpeed;
  late final double rotationDirection;

  /// fpsによらず速度を一定にするためのパラメータ
  final int fps;

  /// * [size] : The widget size.
  /// * [rotationSpeed] : The object rotation speed.
  /// * [rotationDirection] : Specifies whether to rotate
  /// the object counterclockwise or clockwise, as 1 or -1.
  /// If not specified, a random value will be set.
  /// * [baseFallSpeed] :　Parameters for control of falling speed.
  /// The actual speed is obtained by adding 0 to 1 to this speed.
  /// * [fps] : The screen fps.
  HirahiraDropPhysics(this.size,
      {double? rotationSpeed,
      double? rotationDirection,
      this.baseFallSpeed = 0.7,
      this.fps = 60}) {
    this.rotationSpeed = rotationSpeed ?? Random().nextDouble() / 10 + 0.01;
    this.rotationDirection =
        rotationDirection ?? (Random().nextBool() ? 1.0 : -1.0);
    rotateAxis = Random().nextDouble() < 0.8
        ? Sp3dV3D(1, 1, 0).nor()
        : Sp3dV3D(-1, 1, 0).nor();
    _fallSpeed = Random().nextDouble() + baseFallSpeed;
  }

  /// object speed.
  @override
  double get speed {
    return 60 / fps;
  }

  double _convertSineWave(double v) {
    double value = (2 * pi * v * speed) / (size.width / _shiftValue);
    return sin(value);
  }

  /// object motion velocity.
  @override
  Sp3dV3D? get velocity {
    _nowPoint += 1;
    if (_nowPoint * speed > (size.width / _shiftValue)) {
      _nowPoint = 1;
    }
    final double x = (_convertSineWave(_nowPoint) * _lrMovement).toDouble();
    return Sp3dV3D(0, -1 * _fallSpeed * speed, 0) + Sp3dV3D(x * speed, 0, 0);
  }

  /// object rotation parameter.
  @override
  double? get angularVelocity => rotationDirection * rotationSpeed * speed;
}
