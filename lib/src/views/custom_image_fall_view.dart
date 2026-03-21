import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:sakura_blizzard/sakura_blizzard.dart';

///
/// (en) This is a highly customizable view that gives the effect of the
///      specified image falling. Asset paths are passed directly and loading
///      is handled internally. While loading, the child widget is displayed
///      as-is. Physics behavior and initial object positions are fully
///      controlled via factory functions provided by the caller.
///
/// (ja) 指定した画像が落下する、高度にカスタマイズ可能なビューです。
///      アセットパスを直接渡すことができ、読み込み処理は内部で自動化されます。
///      読み込み中は child がそのまま表示されます。
///      Physics の挙動とオブジェクトの初期位置は、呼び出し側が渡す
///      Factory 関数で自由に制御できます。
///
class CustomImageFallView extends StatefulWidget {
  final Widget child;
  final Size viewSize;
  final List<String> assetPaths;
  final List<String> backAssetPaths;
  final int frontObjNum;
  final int backObjNum;
  final double minBrightness;
  final int fps;
  final bool showIndicatorOnLoading;
  final bool enablePositionReset;

  /// (en) Factory function that returns a Physics instance for each object.
  /// Called once per object at initialization.
  ///
  /// (ja) オブジェクトごとに呼ばれる Physics の Factory 関数。
  /// 初期化時にオブジェクト1つにつき1回呼ばれます。
  final Sp3dPhysics Function() physicsCreation;

  /// (en) Factory function that returns the size (width & height) of each object.
  ///
  /// (ja) オブジェクトのサイズを返す Factory 関数。
  ///
  /// * [isFront] : true if the object belongs to the front layer.
  final double Function(bool isFront) sizeCreation;

  /// (en) Factory function that returns the initial position of each object.
  ///
  /// (ja) オブジェクトの初期位置を返す Factory 関数。
  ///
  /// * [isFront] : true if the object belongs to the front layer.
  /// * [viewSize] : The size of this view, for convenience.
  final Sp3dV3D Function(bool isFront, Size viewSize) positionCreation;

  /// (en) Factory function that returns the index of the image to use from
  /// [assetPaths]. If null, a random index is used.
  ///
  /// (ja) 使用する画像のインデックスを返す Factory 関数。
  /// null の場合はランダムに選択されます。
  ///
  /// * [isFront] : true if the object belongs to the front layer.
  /// * [imageCount] : Total number of available images.
  final int Function(bool isFront, int imageCount)? imageIndexCreation;

  /// * [child] : A child view will placed between the front and back layers.
  ///   This child will be displayed even while loading.
  /// * [viewSize] : This view size.
  /// * [assetPaths]: List of asset paths for the front image.
  /// * [backAssetPaths]: List of asset paths for the back image.
  ///   Specify the same number and order as [assetPaths].
  /// * [frontObjNum] : Number of front layer objects you want to generate.
  /// * [backObjNum] : Number of back layer objects you want to generate.
  /// * [minBrightness] : The maximum magnification of how dark the object
  ///   will be when rotated. 0 is the darkest,
  ///   and 1 means the brightness will not change.
  /// * [fps] : The screen fps.
  /// * [physicsCreation] : Factory function returning a Physics instance.
  /// * [sizeCreation] : Factory function returning the object size.
  /// * [positionCreation] : Factory function returning the initial position.
  /// * [imageIndexCreation] : Factory function returning the image index.
  ///   If null, a random index is used.
  /// * [showIndicatorOnLoading] : If true, an indicator will be displayed
  /// while loading. If false, the child will be displayed.
  /// * [enablePositionReset] : Specifies whether the object's position is
  /// reset after it falls. Set to false for one-time effects.
  const CustomImageFallView({
    required this.child,
    required this.viewSize,
    required this.assetPaths,
    required this.backAssetPaths,
    required this.physicsCreation,
    required this.sizeCreation,
    required this.positionCreation,
    this.frontObjNum = 20,
    this.backObjNum = 20,
    this.minBrightness = 0.0,
    this.fps = 60,
    this.imageIndexCreation,
    this.showIndicatorOnLoading = true,
    this.enablePositionReset = true,
    super.key,
  });

  @override
  State<CustomImageFallView> createState() => _CustomImageFallViewState();
}

class _CustomImageFallViewState extends State<CustomImageFallView> {
  final List<Sp3dObj> _frontObjs = [];
  final List<Sp3dObj> _backObjs = [];
  final Random _random = Random();
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _loadAndBuild();
  }

  Sp3dObj _createObj(
    bool isFront,
    List<Uint8List> imgs,
    List<Uint8List> backImgs,
  ) {
    final int resolvedIndex = widget.imageIndexCreation != null
        ? widget.imageIndexCreation!(isFront, imgs.length)
        : _random.nextInt(imgs.length);

    final double objSize = widget.sizeCreation(isFront);
    final Sp3dObj r = UtilImageTileCreator.imageTile(
        objSize, imgs[resolvedIndex], backImgs[resolvedIndex]);

    final Sp3dPhysics physics = widget.physicsCreation();
    r.physics = physics;
    if (physics.rotateAxis != null) {
      r.rotate(physics.rotateAxis!, _random.nextDouble() * 360 * pi / 180);
    }

    r.move(widget.positionCreation(isFront, widget.viewSize));
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
        _frontObjs.add(_createObj(true, imgs, backImgs));
      }
      for (int i = 0; i < widget.backObjNum; i++) {
        _backObjs.add(_createObj(false, imgs, backImgs));
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
