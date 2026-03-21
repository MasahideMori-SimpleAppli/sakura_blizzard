import 'dart:math';

import 'package:simple_3d/simple_3d.dart';

///
/// (en) A class for physics calculations that simulates confetti
///      bursting in a specified direction, like a confetti cannon.
///      Each object flies outward within a spread angle around the given
///      direction, then gradually falls under gravity with air resistance.
///      Once the velocity drops near zero, the object stops automatically.
///
/// (ja) クラッカーのように、指定した方向に向かって紙吹雪が飛び散る
///      動きをシミュレートする物理演算クラスです。
///      各オブジェクトは指定方向を中心に拡散角の範囲内でランダムに飛び出し、
///      重力と空気抵抗によって徐々に落下します。
///      速度がほぼ0になると自動的に停止します。
///
class DirectionalPopPhysics extends Sp3dPhysics {
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

  /// * [direction] : The direction and strength of the explosion.
  ///   The vector's magnitude is used as the base burst speed.
  ///   e.g. Sp3dV3D(0, 5, 0) bursts upward with speed 5.
  /// * [spreadAngle] : The spread angle in radians around [direction].
  ///   0 means all objects fly in exactly the same direction.
  ///   pi means half-sphere spread.
  ///   2*pi means full random direction (same as ConfettiPopPhysics).
  /// * [speedVariance] : Random variance added to the base burst speed.
  ///   The actual speed is in [magnitude, magnitude + speedVariance].
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
  DirectionalPopPhysics({
    required Sp3dV3D direction,
    double spreadAngle = pi / 4,
    double speedVariance = 2.0,
    this.gravity = 0.15,
    this.damping = 0.98,
    this.stopThreshold = 0.01,
    double? rotationSpeed,
    double? rotationDirection,
    this.fps = 60,
  })  : _vx = 0,
        _vy = 0 {
    final Random random = Random();

    // direction の大きさを基本速度として使用
    final double magnitude = direction.len();
    final double baseAngle = atan2(direction.y, direction.x);

    // 拡散角の範囲内でランダムにオフセット
    final double angleOffset = (random.nextDouble() - 0.5) * spreadAngle;
    final double finalAngle = baseAngle + angleOffset;

    // 速度のばらつきを加算
    final double finalSpeed = magnitude + random.nextDouble() * speedVariance;
    _vx = cos(finalAngle) * finalSpeed;
    _vy = sin(finalAngle) * finalSpeed;

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
