import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:util_simple_3d/util_simple_3d.dart';
import 'package:sakura_blizzard/sakura_blizzard.dart';

///
/// (en) This is a view that gives the effect of the specified image falling.
///      Asset paths are passed directly and loading is handled internally.
///      While loading, the child widget is displayed as-is.
///
/// (ja) 指定した画像が落下するビューです。
///      アセットパスを直接渡すことができ、読み込み処理は内部で自動化されます。
///      読み込み中は child がそのまま表示されます。
///
class AssetImageFallView extends StatefulWidget {
  final Widget child;
  final Size viewSize;
  final List<String> assetPaths;
  final List<String> backAssetPaths;
  final bool isRandomPositionY;
  final int frontObjNum;
  final int backObjNum;
  final VRange frontObjSize;
  final VRange backObjSize;
  final EnumDropType dropType;
  final double minBrightness;
  final int fps;
  final Sp3dPhysics Function()? customPhysicsCreation;
  final bool showIndicatorOnLoading;
  final bool enablePositionReset;

  /// * [child] : A child view will placed between the front and back layers.
  ///   This child will be displayed even while loading.
  /// * [viewSize]: This view size.
  /// * [assetPaths]: List of asset paths for the front image.
  /// * [backAssetPaths]: List of asset paths for the back image.
  ///   Specify the same number and order as [assetPaths].
  /// * [isRandomPositionY] : Specifies whether to randomize the y-coordinate
  ///   at which the object starts falling.
  /// * [frontObjNum] : Number of front layer objects you want to generate.
  /// * [backObjNum] : Number of back layer objects you want to generate.
  /// * [frontObjSize] : The size range of the objects you want to generate
  ///   in front layer.
  /// * [backObjSize] : The size range of the objects you want to generate
  ///   in back layer.
  /// * [dropType] : Specifying the type of animation while falling.
  /// * [fps] : The screen fps.
  /// * [minBrightness] : The maximum magnification of how dark the object
  ///   will be when rotated. 0 is the darkest,
  ///   and 1 means the brightness will not change.
  /// * [customPhysicsCreation] : You can create your own behavior and use it.
  ///   If this is not null, the dropType parameter is ignored.
  /// * [showIndicatorOnLoading] : If true, an indicator will be displayed
  /// while loading. If false, the child will be displayed.
  /// * [enablePositionReset] : Specifies whether the object's position is
  /// reset after it falls. Set to false for one-time effects.
  const AssetImageFallView({
    required this.child,
    required this.viewSize,
    required this.assetPaths,
    required this.backAssetPaths,
    this.isRandomPositionY = true,
    this.frontObjNum = 20,
    this.backObjNum = 20,
    this.frontObjSize = const VRange(min: 8, max: 32),
    this.backObjSize = const VRange(min: 8, max: 32),
    this.dropType = EnumDropType.hirahiraDrop,
    this.fps = 60,
    this.minBrightness = 0.0,
    this.customPhysicsCreation,
    this.showIndicatorOnLoading = true,
    this.enablePositionReset = true,
    super.key,
  });

  @override
  State<AssetImageFallView> createState() => _AssetImageFallViewState();
}

class _AssetImageFallViewState extends State<AssetImageFallView> {
  final List<Sp3dObj> _frontObjs = [];
  final List<Sp3dObj> _backObjs = [];
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _loadAndBuild();
  }

  Sp3dPhysics _getDropPhysics() {
    if (widget.customPhysicsCreation != null) {
      return widget.customPhysicsCreation!();
    }
    switch (widget.dropType) {
      case EnumDropType.rotatingDrop:
        return RotatingDropPhysics(fps: widget.fps);
      case EnumDropType.spinDrop3D:
        return SpinDrop3DPhysics(fps: widget.fps);
      case EnumDropType.hirahiraDrop:
        return HirahiraDropPhysics(widget.viewSize, fps: widget.fps);
      case EnumDropType.basicDrop:
        return BasicDropPhysics();
      case EnumDropType.rainDrop:
        return RainDropPhysics();
    }
  }

  Sp3dObj _createObj(
    VRange targetSize,
    List<Uint8List> imgs,
    List<Uint8List> backImgs,
  ) {
    final double objSize = targetSize.getRandomInRange();
    final int targetImageIndex = Random().nextInt(imgs.length);
    final Sp3dObj r = UtilImageTileCreator.imageTile(
        objSize, imgs[targetImageIndex], backImgs[targetImageIndex]);
    r.physics = _getDropPhysics();
    if (r.physics!.rotateAxis != null) {
      r.rotate(r.physics!.rotateAxis!, Random().nextDouble() * 360 * pi / 180);
    }
    if (widget.isRandomPositionY) {
      r.move(Sp3dV3D(widget.viewSize.width * Random().nextDouble(),
          (widget.viewSize.height * 1.125) * Random().nextDouble(), 0));
    } else {
      r.move(Sp3dV3D(widget.viewSize.width * Random().nextDouble(), 0, 0));
    }
    return r;
  }

  Future<void> _loadAndBuild() async {
    final List<Uint8List> imgs = await Future.wait(
      widget.assetPaths.map((p) async {
        final ByteData bd = await rootBundle.load(p);
        return bd.buffer.asUint8List(bd.offsetInBytes, bd.lengthInBytes);
      }),
    );
    final List<Uint8List> backImgs = await Future.wait(
      widget.backAssetPaths.map((p) async {
        final ByteData bd = await rootBundle.load(p);
        return bd.buffer.asUint8List(bd.offsetInBytes, bd.lengthInBytes);
      }),
    );

    if (!mounted) return;

    setState(() {
      for (int i = 0; i < widget.frontObjNum; i++) {
        _frontObjs.add(_createObj(widget.frontObjSize, imgs, backImgs));
      }
      for (int i = 0; i < widget.backObjNum; i++) {
        _backObjs.add(_createObj(widget.backObjSize, imgs, backImgs));
      }
      _isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return widget.showIndicatorOnLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(children: [widget.child]);
    }
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
        showIndicatorOnLoading: widget.showIndicatorOnLoading,
        enablePositionReset: widget.enablePositionReset,
        child: widget.child,
      );
    });
  }
}
