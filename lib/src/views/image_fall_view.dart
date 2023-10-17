import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:util_simple_3d/util_simple_3d.dart';
import '../../sakura_blizzard.dart';

///
/// (en) This is a view that gives the effect of the specified image falling.
///
/// (ja) 指定した画像が落下するビューです。
///
/// Author Masahide Mori
///
class ImageFallView extends StatefulWidget {
  final Widget child;
  final Size viewSize;
  final List<Uint8List> images;
  final List<Uint8List> backImages;
  final bool isRandomPositionY;
  final int frontObjNum;
  final int backObjNum;
  final VRange frontObjSize;
  final VRange backObjSize;
  final EnumDropType dropType;
  final double minBrightness;
  final int fps;
  final Sp3dPhysics Function()? customPhysicsCreation;

  /// * [child] : A child view will placed between the front and back layers.
  /// * [viewSize] : This view size.
  /// * [images] : A list of images you want to drop.
  /// If multiple images are specified,
  /// the image to be used will be randomly selected during initialization.
  /// * [backImages] : List of images on the back. Must be the same number and
  /// in the same order as the surface.
  /// * [isRandomPositionY] : Specifies whether to randomize the y-coordinate
  /// at which the object starts falling.
  /// * [frontObjNum] : Number of front layer objects you want to generate.
  /// * [backObjNum] : Number of back layer objects you want to generate.
  /// * [frontObjSize] : The size range of the objects you want to generate
  /// in front layer.
  /// A randomly sized object is generated within the range.
  /// * [backObjSize] : The size range of the objects you want to generate
  /// in back layer.
  /// A randomly sized object is generated within the range.
  /// * [dropType] : Specifying the type of animation while falling.
  /// * [fps] : The screen fps.
  /// * [minBrightness] : The maximum magnification of how dark the object
  /// will be when rotated. 0 is the darkest,
  /// and 1 means the brightness will not change.
  /// * [customPhysicsCreation] : You can create your own behavior and use it.
  /// If this is not null, the dropType parameter is ignored.
  const ImageFallView(
      {required this.child,
      required this.viewSize,
      required this.images,
      required this.backImages,
      this.isRandomPositionY = true,
      this.frontObjNum = 20,
      this.backObjNum = 20,
      this.frontObjSize = const VRange(min: 8, max: 32),
      this.backObjSize = const VRange(min: 8, max: 32),
      this.dropType = EnumDropType.hirahiraDrop,
      this.fps = 60,
      this.minBrightness = 0.0,
      this.customPhysicsCreation,
      super.key});

  @override
  State<ImageFallView> createState() => _ImageFallViewState();

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
    }
  }

  /// Creates an object with the specified size range.
  /// * [targetSize] : The size range of generation object.
  Sp3dObj createObj(VRange targetSize) {
    final double objSize = targetSize.getRandomInRange();
    final Sp3dObj r = UtilImageTileCreator.imageTile(objSize);
    final int targetImageIndex = Random().nextInt(images.length);
    r.images.add(images[targetImageIndex]);
    r.images.add(backImages[targetImageIndex]);
    r.physics = _getDropPhysics(fps);
    if (r.physics!.rotateAxis != null) {
      r.rotate(r.physics!.rotateAxis!, Random().nextDouble() * 360 * pi / 180);
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

class _ImageFallViewState extends State<ImageFallView> {
  final List<Sp3dObj> _frontObjs = [];
  final List<Sp3dObj> _backObjs = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.frontObjNum; i++) {
      _frontObjs.add(widget.createObj(widget.frontObjSize));
    }
    for (int i = 0; i < widget.backObjNum; i++) {
      _backObjs.add(widget.createObj(widget.backObjSize));
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
