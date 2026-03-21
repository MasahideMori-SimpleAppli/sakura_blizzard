import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:sakura_blizzard/sakura_blizzard.dart';

///
/// (en) A general-purpose view that gives the effect of any Sp3dObj falling.
///      The object to drop is fully controlled via a factory function
///      provided by the caller, including its physics, size, and position.
///
/// (ja) 任意の Sp3dObj が落下するエフェクトの汎用ビューです。
///      落下させるオブジェクトの生成（Physics・サイズ・初期位置を含む）は、
///      呼び出し側が渡す Factory 関数で自由に制御できます。
///
class CustomFallView extends StatefulWidget {
  final Widget child;
  final Size viewSize;
  final int frontObjNum;
  final int backObjNum;
  final double minBrightness;
  final int fps;
  final bool showIndicatorOnLoading;
  final bool enablePositionReset;

  /// (en) Factory function that creates and returns a Sp3dObj for each slot.
  /// Physics, size, and initial position should all be configured here.
  ///
  /// (ja) 各スロットに対して Sp3dObj を生成して返す Factory 関数。
  /// Physics・サイズ・初期位置はすべてここで設定してください。
  ///
  /// * [isFront] : true if the object belongs to the front layer.
  /// * [viewSize] : The size of this view, for convenience.
  final Sp3dObj Function(bool isFront, Size viewSize) objCreation;

  /// * [child] : A child view will placed between the front and back layers.
  /// * [viewSize] : This view size.
  /// * [objCreation] : Factory function returning a Sp3dObj.
  ///   Physics, size, and initial position should all be set inside.
  /// * [frontObjNum] : Number of front layer objects you want to generate.
  /// * [backObjNum] : Number of back layer objects you want to generate.
  /// * [minBrightness] : The maximum magnification of how dark the object
  ///   will be when rotated. 0 is the darkest,
  ///   and 1 means the brightness will not change.
  /// * [fps] : The screen fps.
  /// * [showIndicatorOnLoading] : If true, an indicator will be displayed
  /// while loading. If false, the child will be displayed.
  /// * [enablePositionReset] : Specifies whether the object's position is
  /// reset after it falls. Set to false for one-time effects.
  const CustomFallView({
    required this.child,
    required this.viewSize,
    required this.objCreation,
    this.frontObjNum = 20,
    this.backObjNum = 20,
    this.minBrightness = 0.80,
    this.fps = 60,
    this.showIndicatorOnLoading = true,
    this.enablePositionReset = true,
    super.key,
  });

  @override
  State<CustomFallView> createState() => _CustomFallViewState();
}

class _CustomFallViewState extends State<CustomFallView> {
  final List<Sp3dObj> _frontObjs = [];
  final List<Sp3dObj> _backObjs = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.frontObjNum; i++) {
      _frontObjs.add(widget.objCreation(true, widget.viewSize));
    }
    for (int i = 0; i < widget.backObjNum; i++) {
      _backObjs.add(widget.objCreation(false, widget.viewSize));
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
        showIndicatorOnLoading: widget.showIndicatorOnLoading,
        enablePositionReset: widget.enablePositionReset,
        child: widget.child,
      );
    });
  }
}
