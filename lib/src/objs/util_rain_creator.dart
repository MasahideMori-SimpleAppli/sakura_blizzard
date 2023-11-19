import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:util_simple_3d/util_simple_3d.dart';

///
/// (en) A utility for generating planar rain objects.
///
/// (ja) 平面的な雨のオブジェクトを生成するためのユーティリティ。
///
/// Author Masahide Mori
///
class UtilRainCreator {
  /// (en)Generates the coordinates of a quadrilateral tile with the (0,0,0) point as the center.
  ///
  /// (ja)(0,0,0)点を中心とした四角形タイルの座標を生成します。
  ///
  /// * [w] : width.
  /// * [h] : height.
  /// * [zPosition] : base z position.
  ///
  /// Returns 3d simple tile vertices.
  static List<Sp3dV3D> _tileV3d(double w, double h, double zPosition) {
    final double startX = -w / 2;
    final double startY = h / 2;
    final double endX = w / 2;
    final double endY = -h / 2;
    return [
      Sp3dV3D(startX, startY, zPosition),
      Sp3dV3D(startX, endY, zPosition),
      Sp3dV3D(endX, endY, zPosition),
      Sp3dV3D(endX, startY, zPosition)
    ];
  }

  /// (en)Generates a planar rain object centered at the (0,0,0) point.
  ///
  /// (ja)(0,0,0)点を中心とした平面的な雨のオブジェクトを生成します。
  ///
  /// * [width] : The length of one side of a square tile.
  /// * [height] : The length of one side of a square tile.
  /// * [objColor] : The color of generation object.
  ///
  /// Returns 3d cube obj.
  static Sp3dObj rain(double width, double height, Color objColor) {
    List<Sp3dV3D> vertices = _tileV3d(width, height, 0);
    return Sp3dObj(vertices, [
      Sp3dFragment([Sp3dFace(UtilSp3dList.getIndexes(vertices, 0), 0)])
    ], [
      Sp3dMaterial(objColor, true, 0, objColor)
    ], []);
  }
}
