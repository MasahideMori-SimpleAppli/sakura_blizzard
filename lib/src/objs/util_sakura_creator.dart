import 'package:simple_3d/simple_3d.dart';
import 'package:util_simple_3d/util_simple_3d.dart';
import 'package:sakura_blizzard/src/colors/sakura_blizzard_materials.dart';

///
/// (en) A utility for generating cherry blossom petal objects.
///
/// (ja) 桜の花びらオブジェクトを生成するためのユーティリティ。
///
/// Author Masahide Mori
///
class UtilSakuraCreator {
  /// (en)Generates the coordinates of the cherry blossom petals centered on
  /// the (0,0,zPosition) point.
  ///
  /// (ja)(0,0,zPosition)点を中心とした桜の花びらの座標を生成します。
  ///
  /// * [w] : width.
  /// * [h] : height.
  /// * [notchLen] : The petal notch length.
  /// * [resolution] : The number of points that make up a petal.
  /// This must be a number divisible by 2.
  /// The points are excluding notches and bottom point.
  /// * [zPosition] : base z position.
  ///
  /// Returns 3d sakuraPetal vertices.
  static List<Sp3dV3D> _sakuraPetalV3d(double w, double h, double notchLen,
      {int resolution = 12, double zPosition = 0}) {
    final double left = -w / 2;
    final double right = w / 2;
    final double top = h / 2;
    final double bottom = -h / 2;
    final Sp3dV3D notchCenter = Sp3dV3D(0, top - notchLen, zPosition);
    final Sp3dV3D notchLeft = Sp3dV3D(left / 2, top, zPosition);
    final Sp3dV3D notchRight = Sp3dV3D(right / 2, top, zPosition);
    final Sp3dV3D bottomPoint = Sp3dV3D(0, bottom, zPosition);
    final Sp3dV3D mostLeft = Sp3dV3D(left, 0, zPosition);
    final Sp3dV3D mostRight = Sp3dV3D(right, 0, zPosition);
    List<Sp3dV3D> r = [notchCenter, notchLeft];
    //　逆時計回りで作成
    int splitPoints = resolution ~/ 2;
    r.addAll(
        UtilBezier.bezierCurve(notchLeft, mostLeft, bottomPoint, splitPoints));
    r.add(bottomPoint);
    r.addAll(UtilBezier.bezierCurve(
        bottomPoint, mostRight, notchRight, splitPoints));
    r.add(notchRight);
    return r;
  }

  /// (en)Generates one cherry blossom petal centered at the (0,0,0) point.
  /// Please note that there is a slight gap between the front and
  /// back sides of the petals.
  ///
  /// (ja)(0,0,0)点を中心とした１枚の桜の花びらを生成します。
  /// なお、花びらは裏表の面の間にわずかな隙間があることに注意してください。
  ///
  /// * [w] : width.
  /// * [h] : height.
  /// * [notchLen] : The petal notch length.
  /// * [resolution] : The number of points that make up a petal.
  /// This must be a number divisible by 2.
  /// The points are excluding notches and bottom point.
  /// * [zDistance] : This is the distance between the front and back sides
  /// of the petal. Note that the petals created are not touching
  /// front and back to reduce the number of meshes.
  /// Front petals will be generated half this value forward on the z-axis,
  /// and back petals will be generated half this value back on the z-axis.
  ///
  /// Returns 3d cube obj.
  static Sp3dObj sakuraPetal(double w, double h, double notchLen,
      {int resolution = 12, double zDistance = 0.0002}) {
    List<Sp3dV3D> front = _sakuraPetalV3d(w, h, notchLen,
        resolution: resolution, zPosition: zDistance / 2);
    List<Sp3dV3D> back = _sakuraPetalV3d(w, h, notchLen,
            resolution: resolution, zPosition: -1 * zDistance / 2)
        .reversed
        .toList();
    List<Sp3dFragment> fragments = [];
    Sp3dFace frontFace = Sp3dFace(UtilSp3dList.getIndexes(front, 0), 0);
    Sp3dFace backFace =
        Sp3dFace(UtilSp3dList.getIndexes(back, front.length), 0);
    fragments.add(Sp3dFragment([frontFace, backFace]));
    front.addAll(back);
    return Sp3dObj(front, fragments, [SakuraBlizzardMaterials.sakura], []);
  }
}
