import 'package:simple_3d/simple_3d.dart';
import 'package:util_simple_3d/util_simple_3d.dart';

///
/// (en) Utility for generating snow objects.
///
/// (ja) 雪のオブジェクトを生成するためのユーティリティ。
///
/// Author Masahide Mori
///
class UtilSnowCreator {
  /// (en)Generates the coordinates of a circle centered on the (0,0,0) point.
  ///
  /// (ja)(0,0,0)点を中心とした円の座標を生成します。
  ///
  /// * [r] : radius.
  /// * [fragments] : The number of triangles that make up a circle. The more it is, the smoother it becomes.
  /// Divide the area for the angle specified by theta by this number of triangles.
  /// * [theta] : 360 for a circle. 180 for a semicircle. The range is 1-360 degrees.
  ///
  /// Returns 3d circle vertices.
  static List<Sp3dV3D> _snowCircleV3d(double r, int fragments,
      {double theta = 360}) {
    // 回転角（逆時計周り）
    final double radian = theta / fragments * Sp3dConstantValues.toRadian;
    // 始点から終点への軸ベクトルを考える。
    Sp3dV3D norAxis = Sp3dV3D(0, 0, 1);
    // 半径rの回転ベクトル
    List<Sp3dV3D> c = [Sp3dV3D(r, 0, 0)];
    for (int i = 0; i < fragments; i++) {
      c.add(c.last.rotated(norAxis, radian));
    }
    return c;
  }

  /// (en)Generates a circle centered on the (0,0,0) point.
  /// This approximates a circle with a triangle, not a true circle.
  /// This is a modified version of the util_simple3d implementation for lightweight operation.
  ///
  /// (ja)(0,0,0)点を中心とした円を生成します。
  /// これは真の円ではなく、三角形で円を近似します。
  /// これはutil_simple3dの実装を、軽量動作用に改変したバージョンです。
  ///
  /// * [r] : radius.
  /// * [fragments] : The number of triangles that make up a circle. The more it is, the smoother it becomes.
  /// Divide the area for the angle specified by theta by this number of triangles.
  /// * [theta] : 360 for a circle. 180 for a semicircle. The range is 1-360 degrees.
  /// * [material] : face material
  ///
  /// Returns 3d circle obj.
  static Sp3dObj snow(double r,
      {int fragments = 18, double theta = 360, Sp3dMaterial? material}) {
    List<Sp3dV3D> serialized = _snowCircleV3d(r, fragments, theta: theta);
    List<int> indexes = UtilSp3dList.getIndexes(serialized, 0);
    indexes.add(0);
    return Sp3dObj(serialized, [
      Sp3dFragment([Sp3dFace(indexes, 0)])
    ], [
      material ?? FSp3dMaterial.white,
    ], []);
  }
}
