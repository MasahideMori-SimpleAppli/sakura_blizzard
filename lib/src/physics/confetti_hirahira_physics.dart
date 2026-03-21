import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:util_simple_3d/util_simple_3d.dart';

///
/// (en) A class for physics calculations that simulates confetti
///      bursting outward in all directions, then smoothly transitioning
///      to a gentle hirahira (flutter) falling motion via linear
///      interpolation.
///
/// (ja) 全方位に飛び散った後、線形補間によってなめらかに
///      ひらひら落下へ移行する物理演算クラスです。
///
/// Author Masahide Mori
///
class ConfettiHirahiraPhysics extends Sp3dPhysics {
  /// 爆発フェーズの速度（内部状態）
  double _vx;
  double _vy;

  /// 爆発フェーズ
  final double gravity;
  final double damping;

  /// フェーズ管理
  /// 0: 爆発, 1: 遷移, 2: 落下
  int _phase = 0;

  /// 爆発フェーズの最大フレーム数
  final int maxBurstFrames;
  int _burstFrames = 0;

  /// 遷移フェーズのフレーム数と進捗
  final int transitionFrames;
  int _transitionFrames = 0;

  /// 落下フェーズ（HirahiraDrop相当）
  double _nowPoint = 0;
  final double baseFallSpeed;
  late final double _fallSpeed;
  final int _lrMovement = Random().nextBool() ? 1 : -1;
  final double minShiftValue;
  final double maxShiftValue;
  late final double _shiftValue;
  final Size size;
  late final double _targetLength;

  /// 回転関連パラメータ
  late final double rotationSpeed;
  late final double rotationDirection;

  /// fpsによらず速度を一定にするためのパラメータ
  final int fps;

  /// * [size] : The widget size. Used for hirahira fall calculation.
  /// * [minBurstSpeed] : Minimum initial burst speed.
  /// * [maxBurstSpeed] : Maximum initial burst speed.
  /// * [gravity] : Gravitational acceleration during burst phase.
  /// * [damping] : Air resistance damping factor during burst phase (0–1).
  /// * [maxBurstFrames] : Maximum number of frames in the burst phase.
  ///   Defaults to 120 (2 seconds at 60fps).
  /// * [transitionFrames] : Number of frames to smoothly interpolate
  ///   between burst and hirahira phases. Defaults to 60 (1 second at 60fps).
  /// * [baseFallSpeed] : Base falling speed in hirahira phase.
  /// * [minShiftValue] : Min lateral swing range in hirahira phase.
  /// * [maxShiftValue] : Max lateral swing range in hirahira phase.
  /// * [rotationSpeed] : The object rotation speed.
  ///   If not specified, a random value will be set.
  /// * [rotationDirection] : Specifies whether to rotate
  ///   the object counterclockwise or clockwise, as 1 or -1.
  ///   If not specified, a random value will be set.
  /// * [fps] : The screen fps.
  ConfettiHirahiraPhysics(
    this.size, {
    double minBurstSpeed = 3.0,
    double maxBurstSpeed = 8.0,
    this.gravity = 0.15,
    this.damping = 0.98,
    this.maxBurstFrames = 120,
    this.transitionFrames = 60,
    this.baseFallSpeed = 0.7,
    this.minShiftValue = 1.5,
    this.maxShiftValue = 3.0,
    double? rotationSpeed,
    double? rotationDirection,
    this.fps = 60,
  })  : _vx = 0,
        _vy = 0 {
    final Random random = Random();

    // 爆発フェーズの初速（全方位ランダム）
    final double angle = random.nextDouble() * 2 * pi;
    final double speed =
        minBurstSpeed + random.nextDouble() * (maxBurstSpeed - minBurstSpeed);
    _vx = cos(angle) * speed;
    _vy = sin(angle) * speed;

    // 落下フェーズのパラメータ
    _fallSpeed = random.nextDouble() + baseFallSpeed;
    _shiftValue =
        VRange(min: minShiftValue, max: maxShiftValue).getRandomInRange();
    _targetLength = size.width > size.height ? size.width : size.height;

    this.rotationSpeed = rotationSpeed ?? random.nextDouble() / 10 + 0.01;
    this.rotationDirection =
        rotationDirection ?? (random.nextBool() ? 1.0 : -1.0);
    rotateAxis = random.nextDouble() < 0.8
        ? Sp3dV3D(1, 1, 0).nor()
        : Sp3dV3D(-1, 1, 0).nor();
  }

  /// object speed.
  @override
  double get speed => 60 / fps;

  double _convertSineWave(double v) {
    final double value = (2 * pi * v * speed) / (_targetLength / _shiftValue);
    return sin(value);
  }

  /// ひらひら落下の速度ベクトルを計算する。
  Sp3dV3D _calcHirahira() {
    _nowPoint += 1;
    if (_nowPoint * speed > (_targetLength / _shiftValue)) {
      _nowPoint = 1;
    }
    final double x = (_convertSineWave(_nowPoint) * _lrMovement).toDouble();
    return Sp3dV3D(0, -1 * _fallSpeed * speed, 0) + Sp3dV3D(x * speed, 0, 0);
  }

  /// object motion velocity.
  @override
  Sp3dV3D? get velocity {
    if (_phase == 0) {
      // 爆発フェーズ
      _vy -= gravity * speed;
      _vx *= damping;
      _vy *= damping;
      _burstFrames += 1;
      if (_burstFrames >= maxBurstFrames) {
        _phase = 1;
      }
      return Sp3dV3D(_vx, _vy, 0) * speed;
    } else if (_phase == 1) {
      // 遷移フェーズ: 爆発とひらひらをlerpでブレンド
      _vy -= gravity * speed;
      _vx *= damping;
      _vy *= damping;
      _transitionFrames += 1;
      final double t = _transitionFrames / transitionFrames;
      final Sp3dV3D burstV = Sp3dV3D(_vx, _vy, 0) * speed;
      final Sp3dV3D hirahiraV = _calcHirahira();
      if (_transitionFrames >= transitionFrames) {
        _phase = 2;
      }
      // lerp: burst * (1 - t) + hirahira * t
      return (burstV * (1.0 - t)) + (hirahiraV * t);
    } else {
      // 落下フェーズ
      return _calcHirahira();
    }
  }

  /// object rotation parameter.
  @override
  double? get angularVelocity => rotationDirection * rotationSpeed * speed;
}
