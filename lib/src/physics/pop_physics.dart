import 'dart:math';

import 'package:simple_3d/simple_3d.dart';

///
/// (en) A class for physics calculations that simulates confetti
///      bursting outward from the center, like a surprise party popper.
///      Each object flies outward with a random direction and speed,
///      then gradually falls under gravity with air resistance.
///      Once the velocity drops near zero, the object stops automatically.
///
/// (ja) びっくり箱を開けたときの紙吹雪のように、中央から外側に飛び散る
///      動きをシミュレートする物理演算クラスです。
///      各オブジェクトはランダムな方向・速度で飛び出し、
///      重力と空気抵抗によって徐々に落下します。
///      速度がほぼ0になると自動的に停止します。
///
class PopPhysics extends Sp3dPhysics {
  /// 現在の速度ベクトル（内部状態）
  double _vx;
  double _vy;

  /// 重力加速度（毎フレーム _vy に加算される）
  final double gravity;

  /// 空気抵抗による減衰率（0〜1、1に近いほど減衰しない）
  final double damping;

  /// 速度がこの値を下回ったら停止とみなす閾値
  final double stopThreshold;

  /// 回転関連パラメータ
  late final double rotationSpeed;
  late final double rotationDirection;

  /// fpsによらず速度を一定にするためのパラメータ
  final int fps;

  /// * [minBurstSpeed] : Minimum initial burst speed.
  /// * [maxBurstSpeed] : Maximum initial burst speed.
  /// * [gravity] : Gravitational acceleration added to vertical velocity
  ///   each frame. Larger values make objects fall faster.
  /// * [damping] : Air resistance damping factor (0–1).
  ///   1 means no damping, 0 means instant stop.
  /// * [stopThreshold] : The object stops when both vx and vy drop below
  ///   this value. Defaults to 0.01.
  /// * [rotationSpeed] : The object rotation speed.
  ///   If not specified, a random value will be set.
  /// * [rotationDirection] : Specifies whether to rotate
  ///   the object counterclockwise or clockwise, as 1 or -1.
  ///   If not specified, a random value will be set.
  /// * [fps] : The screen fps.
  PopPhysics({
    double minBurstSpeed = 3.0,
    double maxBurstSpeed = 8.0,
    this.gravity = 0.15,
    this.damping = 0.98,
    this.stopThreshold = 0.01,
    double? rotationSpeed,
    double? rotationDirection,
    this.fps = 60,
  })  : _vx = 0,
        _vy = 0 {
    final Random random = Random();

    // ランダムな方向（全方位）と強さで初速を設定
    final double angle = random.nextDouble() * 2 * pi;
    final double speed =
        minBurstSpeed + random.nextDouble() * (maxBurstSpeed - minBurstSpeed);
    _vx = cos(angle) * speed;
    _vy = sin(angle) * speed;

    this.rotationSpeed = rotationSpeed ?? random.nextDouble() / 10 + 0.01;
    this.rotationDirection =
        rotationDirection ?? (random.nextBool() ? 1.0 : -1.0);
    rotateAxis = Sp3dV3D(0, 0, -1);
  }

  /// object speed.
  @override
  double get speed => 60 / fps;

  /// object motion velocity.
  /// 毎フレーム呼ばれるたびに重力加算・減衰を適用して速度を更新する。
  /// 速度がほぼ0になったら null を返して停止する。
  @override
  Sp3dV3D? get velocity {
    // 重力を加算（下方向 = Yのマイナス）
    _vy -= gravity * speed;
    // 空気抵抗で減衰
    _vx *= damping;
    _vy *= damping;
    // 速度がほぼ0になったら止める
    if (_vx.abs() < stopThreshold && _vy.abs() < stopThreshold) return null;
    return Sp3dV3D(_vx, _vy, 0) * speed;
  }

  /// object rotation parameter.
  @override
  double? get angularVelocity => rotationDirection * rotationSpeed * speed;
}
