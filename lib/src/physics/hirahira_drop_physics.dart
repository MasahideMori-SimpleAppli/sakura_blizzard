import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:util_simple_3d/util_simple_3d.dart';

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
  final double minShiftValue;
  final double maxShiftValue;
  late final double _shiftValue;

  /// 親ビューのサイズ情報
  final Size size;

  /// 親ビューの画面のうち、長い方の辺の長さ。
  late final double _targetLength;

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
  /// * [minShiftValue] : Parameters related to petal swing width.
  /// * [maxShiftValue] : Parameters related to petal swing width.
  HirahiraDropPhysics(this.size,
      {double? rotationSpeed,
      double? rotationDirection,
      this.baseFallSpeed = 0.7,
      this.fps = 60,
      this.minShiftValue = 1.5,
      this.maxShiftValue = 3.0}) {
    this.rotationSpeed = rotationSpeed ?? Random().nextDouble() / 10 + 0.01;
    this.rotationDirection =
        rotationDirection ?? (Random().nextBool() ? 1.0 : -1.0);
    rotateAxis = Random().nextDouble() < 0.8
        ? Sp3dV3D(1, 1, 0).nor()
        : Sp3dV3D(-1, 1, 0).nor();
    _fallSpeed = Random().nextDouble() + baseFallSpeed;
    _shiftValue =
        VRange(min: minShiftValue, max: maxShiftValue).getRandomInRange();
    _targetLength = size.width > size.height ? size.width : size.height;
  }

  /// object speed.
  @override
  double get speed {
    return 60 / fps;
  }

  double _convertSineWave(double v) {
    double value = (2 * pi * v * speed) / (_targetLength / _shiftValue);
    return sin(value);
  }

  /// object motion velocity.
  @override
  Sp3dV3D? get velocity {
    _nowPoint += 1;
    if (_nowPoint * speed > (_targetLength / _shiftValue)) {
      _nowPoint = 1;
    }
    final double x = (_convertSineWave(_nowPoint) * _lrMovement).toDouble();
    return Sp3dV3D(0, -1 * _fallSpeed * speed, 0) + Sp3dV3D(x * speed, 0, 0);
  }

  /// object rotation parameter.
  @override
  double? get angularVelocity => rotationDirection * rotationSpeed * speed;
}
