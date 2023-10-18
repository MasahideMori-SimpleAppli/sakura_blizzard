import 'dart:typed_data';

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
    final double startY = -h / 2;
    final double endX = w / 2;
    final double endY = h / 2;
    return [
      Sp3dV3D(startX, startY, zPosition),
      Sp3dV3D(startX, endY, zPosition),
      Sp3dV3D(endX, endY, zPosition),
      Sp3dV3D(endX, startY, zPosition)
    ];
  }

  /// (en)Generates an image indexed tile centered at the (0,0,0) point.
  /// Please note that the tile has two sides, a front and a back,
  /// and there is a slight gap between the front and back.
  ///
  /// (ja)(0,0,0)点を中心とした画像インデックス付きタイルを生成します。
  /// なお、タイルは裏表の両面があり、裏表の間にわずかな隙間があることに注意してください。
  ///
  /// * [objSize] : The length of one side of a square tile.
  /// * [frontImage] : The front image file.
  /// * [backImage] : The back image file.
  /// * [zDistance] : This is the distance between the front and back sides
  /// of the tile Note that the tiles created are not touching.
  /// The previous tile will be generated half this value forward in the Z axis.
  /// The tiles behind will be generated at half this value on the Z axis.
  ///
  /// Returns 3d cube obj.
  static Sp3dObj imageTile(
      double objSize, Uint8List frontImage, Uint8List backImage,
      {double zDistance = 0.0002}) {
    List<Sp3dV3D> front = _tileV3d(objSize, objSize, zDistance / 2);
    List<Sp3dV3D> back =
        _tileV3d(objSize, objSize, -1 * zDistance / 2).reversed.toList();
    List<Sp3dFragment> fragments = [];
    Sp3dFace frontFace = Sp3dFace(UtilSp3dList.getIndexes(front, 0), 0);
    Sp3dFace backFace =
        Sp3dFace(UtilSp3dList.getIndexes(back, front.length), 1);
    fragments.add(Sp3dFragment([frontFace, backFace]));
    front.addAll(back);
    return Sp3dObj(front, fragments,
        [_getImageMaterial(0), _getImageMaterial(1)], [frontImage, backImage]);
  }
}
