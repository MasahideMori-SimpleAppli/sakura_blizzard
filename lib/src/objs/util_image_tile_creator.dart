import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:util_simple_3d/util_simple_3d.dart';

///
/// (en) A utility for generating tile objects set with images.
///
/// (ja) 画像をセットしたタイルオブジェクトを生成するためのユーティリティ。
///
/// Author Masahide Mori
///
class UtilImageTileCreator {
  /// (en) Returns a material with an image specification.
  ///
  /// (ja) 画像指定付きのマテリアルを返します。
  ///
  /// * [imageIndex] : The image index in Sp3dObj.
  static Sp3dMaterial _getImageMaterial(int imageIndex) {
    return Sp3dMaterial(Colors.white, true, 0, Colors.white,
        imageIndex: imageIndex);
  }

  /// (en)Generates an image indexed tile centered at the (0,0,0) point.
  /// Please note that the tile has two sides, a front and a back,
  /// and there is a slight gap between the front and back.
  ///
  /// (ja)(0,0,0)点を中心とした画像インデックス付きタイルを生成します。
  /// なお、タイルは裏表の両面があり、裏表の間にわずかな隙間があることに注意してください。
  ///
  /// * [objSize] : The length of one side of a square tile.
  /// * [zDistance] : This is the distance between the front and back sides
  /// of the tile Note that the tiles created are not touching.
  /// The previous tile will be generated half this value forward in the Z axis.
  /// The tiles behind will be generated at half this value on the Z axis.
  ///
  /// Returns 3d cube obj.
  static Sp3dObj imageTile(double objSize, {double zDistance = 0.0002}) {
    final Sp3dObj front = UtilSp3dGeometry.tile(objSize, objSize, 1, 1,
        material: _getImageMaterial(0));
    final Sp3dObj back = UtilSp3dGeometry.tile(objSize, objSize, 1, 1,
        material: _getImageMaterial(1));
    back.rotate(Sp3dV3D(0, 1, 0).nor(), 180 * Sp3dConstantValues.toRadian);
    front.move(Sp3dV3D(0, 0, zDistance / 2));
    back.move(Sp3dV3D(0, 0, -1 * zDistance / 2));
    return front.merge(back);
  }
}
