import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';

///
/// (en) A set of materials used in SakuraBlizzard.
///
/// (ja) SakuraBlizzardで使用するマテリアルのセット。
///
/// Author Masahide Mori
///
class SakuraBlizzardMaterials {
  static final Sp3dMaterial sakura = Sp3dMaterial(
      const Color.fromARGB(255, 254, 238, 237),
      true,
      1,
      const Color.fromARGB(255, 254, 238, 237));

  static final Sp3dMaterial sakuraWire = Sp3dMaterial(
      const Color.fromARGB(255, 254, 238, 237),
      false,
      1,
      const Color.fromARGB(255, 254, 238, 237));

  static final Sp3dMaterial sakuraNonWire = Sp3dMaterial(
      const Color.fromARGB(255, 254, 238, 237),
      true,
      0,
      const Color.fromARGB(0, 254, 238, 237));

  static final Sp3dMaterial yellow = Sp3dMaterial(
      const Color.fromARGB(255, 255, 235, 59),
      true,
      1,
      const Color.fromARGB(255, 255, 235, 59));

  static final Sp3dMaterial yellowWire = Sp3dMaterial(
      const Color.fromARGB(255, 255, 235, 59),
      false,
      1,
      const Color.fromARGB(255, 255, 235, 59));

  static final Sp3dMaterial yellowNonWire = Sp3dMaterial(
      const Color.fromARGB(255, 255, 235, 59),
      true,
      0,
      const Color.fromARGB(255, 255, 235, 59));
}
