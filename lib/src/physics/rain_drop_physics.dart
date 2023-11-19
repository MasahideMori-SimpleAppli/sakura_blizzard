import 'package:simple_3d/simple_3d.dart';

///
/// (en) A class for physics calculations that can simulate falling motion without rotation.
/// Falling fast like rain.
///
/// (ja) 回転せずに落下する動きをシミュレート可能な、物理演算のためのクラスです。
/// 雨のように高速に落下します。
///
/// Author Masahide Mori
///
class RainDropPhysics extends Sp3dPhysics {
  /// fpsによらず速度を一定にするためのパラメータ
  final int fps;

  /// * [fps] : The screen fps.
  RainDropPhysics({this.fps = 60});

  /// object speed.
  @override
  double? get speed {
    return 60 / fps;
  }

  /// object motion velocity.
  @override
  Sp3dV3D? get velocity {
    return Sp3dV3D(0, -12, 0) * speed!;
  }
}
