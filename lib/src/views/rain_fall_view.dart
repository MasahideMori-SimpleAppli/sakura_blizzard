import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:util_simple_3d/util_simple_3d.dart';
import '../../sakura_blizzard.dart';

///
/// (en) A view of falling rain.
///
/// (ja) 雨が落下するビューです。
///
/// Author Masahide Mori
///
class RainFallView extends StatefulWidget {
  final Widget child;
  final Size viewSize;
  final bool isRandomPositionY;
  final int frontObjNum;
  final int backObjNum;
  final VRange frontObjWidth;
  final VRange frontObjHeight;
  final Color frontObjColor;
  final VRange backObjWidth;
  final VRange backObjHeight;
  final Color backObjColor;
  final EnumDropType dropType;
  final double minBrightness;
  final int fps;
  final Sp3dPhysics Function()? customPhysicsCreation;

  /// * [child] : A child view will placed between the front and back layers.
  /// * [viewSize] : This view size.
  /// * [isRandomPositionY] : Specifies whether to randomize the y-coordinate
  /// at which the object starts falling.
  /// * [frontObjNum] : Number of front layer objects you want to generate.
  /// * [backObjNum] : Number of back layer objects you want to generate.
  /// * [frontObjWidth]
  /// * [frontObjHeight] : The size range of the objects you want to generate
  /// in front layer.
  /// A randomly sized object is generated within the range.
  /// * [frontObjColor] : The font layer rain color.
  /// * [backObjWidth]
  /// * [backObjHeight] : The size range of the objects you want to generate
  /// in back layer.
  /// A randomly sized object is generated within the range.
  /// * [backObjColor] : The back layer rain color.
  /// * [dropType] : Specifying the type of animation while falling.
  /// * [fps] : The screen fps.
  /// * [minBrightness] : The maximum magnification of how dark the object
  /// will be when rotated. 0 is the darkest,
  /// and 1 means the brightness will not change.
  /// * [customPhysicsCreation] : You can create your own behavior and use it.
  /// If this is not null, the dropType parameter is ignored.
  const RainFallView(
      {required this.child,
      required this.viewSize,
      this.isRandomPositionY = true,
      this.frontObjNum = 30,
      this.backObjNum = 30,
      this.frontObjHeight = const VRange(min: 20, max: 140),
      this.frontObjWidth = const VRange(min: 1, max: 3),
      this.frontObjColor = Colors.white,
      this.backObjHeight = const VRange(min: 20, max: 120),
      this.backObjWidth = const VRange(min: 1, max: 2),
      this.backObjColor = Colors.blueGrey,
      this.dropType = EnumDropType.rainDrop,
      this.fps = 60,
      this.minBrightness = 0.93,
      this.customPhysicsCreation,
      super.key});

  @override
  State<RainFallView> createState() => _RainFallViewState();

  /// Convert enum to physics object.
  Sp3dPhysics _getDropPhysics(int fps) {
    if (customPhysicsCreation != null) {
      return customPhysicsCreation!();
    }
    switch (dropType) {
      case EnumDropType.rotatingDrop:
        return RotatingDropPhysics(fps: fps);
      case EnumDropType.spinDrop3D:
        return SpinDrop3DPhysics(fps: fps);
      case EnumDropType.hirahiraDrop:
        return HirahiraDropPhysics(viewSize, fps: fps);
      case EnumDropType.basicDrop:
        return BasicDropPhysics();
      case EnumDropType.rainDrop:
        return RainDropPhysics();
    }
  }

  /// Creates an object with the specified size range.
  /// * [targetWidth] : The width range of generation object.
  /// * [targetHeight] : The height range of generation object.
  /// * [objColor] : The color of generation object.
  Sp3dObj createObj(VRange targetWidth, VRange targetHeight, Color objColor) {
    final double objW = targetWidth.getRandomInRange();
    final double objH = targetHeight.getRandomInRange();
    final Sp3dObj r = UtilRainCreator.rain(
        objW, objH, objColor); // UtilSp3dGeometry.tile(objW, objH, 1, 1);
    r.physics = _getDropPhysics(fps);
    if (r.physics!.rotateAxis != null) {
      // r.rotate(r.physics!.rotateAxis!, Random().nextDouble() * 360 * pi / 180);
    }
    if (isRandomPositionY) {
      r.move(Sp3dV3D(viewSize.width * Random().nextDouble(),
          (viewSize.height * 1.125) * Random().nextDouble(), 0));
    } else {
      r.move(Sp3dV3D(viewSize.width * Random().nextDouble(), 0, 0));
    }
    return r;
  }
}

class _RainFallViewState extends State<RainFallView> {
  final List<Sp3dObj> _frontObjs = [];
  final List<Sp3dObj> _backObjs = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.frontObjNum; i++) {
      _frontObjs.add(widget.createObj(
          widget.frontObjWidth, widget.frontObjHeight, widget.frontObjColor));
    }
    for (int i = 0; i < widget.backObjNum; i++) {
      _backObjs.add(widget.createObj(
          widget.backObjWidth, widget.backObjHeight, widget.backObjColor));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Change detection handling for platforms where window sizes change.
    // Force reconfiguration by UniqueKey.
    return LayoutBuilder(builder: (context, boxConstraints) {
      return ElementsFlowView(
        viewSize: widget.viewSize,
        frontLayerElements: _frontObjs,
        backLayerElements: _backObjs,
        minBrightness: widget.minBrightness,
        fps: widget.fps,
        key: UniqueKey(),
        child: widget.child,
      );
    });
  }
}
