import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:simple_3d_renderer/simple_3d_renderer.dart';

///
/// (en) A general-purpose view for creating 3D effects.
/// This widget is intended to be used as a child widget.
///
/// (ja) 3Dエフェクト作成用の汎用のビューです。
/// このウィジェットは子ウィジェットとして使用されることを想定しています。
///
/// Author Masahide Mori
///
class ElementsFlowView extends StatefulWidget {
  final Widget child;
  final Size viewSize;
  final List<Sp3dObj> frontLayerElements;
  final List<Sp3dObj> backLayerElements;
  final int fps;
  final double minBrightness;
  final bool resetRandomX;

  /// * [child] : A child view will placed between the front and back layers.
  /// * [viewSize] : This view size.
  /// * [frontLayerElements] : A list of objects to place on the front layer.
  /// * [backLayerElements] : A list of objects to place on the back layer.
  /// * [fps] : The screen fps.
  /// * [minBrightness] : The maximum magnification of how dark the object
  /// will be when rotated. 0 is the darkest,
  /// and 1 means the brightness will not change.
  /// * [resetRandomX] : Specifies whether to change the x coordinate
  /// when the object falls to the bottom and then falls again from the top.
  const ElementsFlowView(
      {required this.child,
      required this.viewSize,
      required this.frontLayerElements,
      required this.backLayerElements,
      this.fps = 60,
      this.minBrightness = 0.80,
      this.resetRandomX = true,
      super.key});

  @override
  State<ElementsFlowView> createState() => _ElementsFlowViewState();

  /// (en) Method to update the object's position.
  /// This method is called inside the timer at fps dependent timing.
  ///
  /// (ja) タイマーによって、指定fps依存のタイミングで
  /// オブジェクトの位置を更新するメソッドです。
  ///
  /// * [obj] : The target object of position update.
  void updateObjPosition(Sp3dObj obj) {
    if (obj.physics != null && obj.physics!.velocity != null) {
      obj.move(obj.physics!.velocity!);
      // reset position
      if (obj.getCenter().y < -1 * (viewSize.height / 8)) {
        if (resetRandomX) {
          final Sp3dV3D diff = Sp3dV3D(0, 0, 0) - obj.getCenter();
          obj.move(diff);
          obj.move(Sp3dV3D(viewSize.width * Random().nextDouble(),
              viewSize.height * 1.125, 0));
        } else {
          obj.move(Sp3dV3D(0, viewSize.height * 1.125, 0));
        }
      }
      // object rotation
      if (obj.physics!.rotateAxis != null &&
          obj.physics!.angularVelocity != null) {
        obj.rotateInPlace(
            obj.physics!.rotateAxis!, obj.physics!.angularVelocity!);
      }
    }
  }
}

class _ElementsFlowViewState extends State<ElementsFlowView> {
  late final Sp3dCamera _camera;
  Sp3dWorld? _backWorld;
  bool _backWorldLoaded = false;
  Sp3dWorld? _frontWorld;
  bool _frontWorldLoaded = false;
  final ValueNotifier<int> _vn = ValueNotifier(0);
  late final Sp3dLight _light;

  /// FPS調整用
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _light = Sp3dLight(Sp3dV3D(0, 0, -1), minBrightness: widget.minBrightness);
    _camera = Sp3dOrthographicCamera(
        Sp3dV3D(widget.viewSize.width / 2, widget.viewSize.height / 2, 3000),
        6000);
    _timer =
        Timer.periodic(Duration(milliseconds: 1000 ~/ widget.fps), (Timer t) {
      for (Sp3dObj i in widget.frontLayerElements) {
        widget.updateObjPosition(i);
      }
      for (Sp3dObj i in widget.backLayerElements) {
        widget.updateObjPosition(i);
      }
      _vn.value += 1; // 状態の更新
    });
    _loadImage();
  }

  @override
  void dispose() {
    _vn.dispose();
    if (_timer != null) {
      if (_timer!.isActive) {
        _timer!.cancel();
      }
    }
    super.dispose();
  }

  void _loadImage() {
    _backWorld = Sp3dWorld(widget.backLayerElements);
    _backWorld!.initImages().then((List<Sp3dObj> errorObjs) {
      setState(() {
        _backWorldLoaded = true;
      });
    });
    _frontWorld = Sp3dWorld(widget.frontLayerElements);
    _frontWorld!.initImages().then((List<Sp3dObj> errorObjs) {
      setState(() {
        _frontWorldLoaded = true;
      });
    });
  }

  /// 必要な分だけスタックの内容を返します。
  List<Widget> _getStackChildren() {
    if (widget.backLayerElements.isEmpty &&
        widget.frontLayerElements.isNotEmpty) {
      return [
        widget.child,
        Sp3dRenderer(
          widget.viewSize,
          Sp3dV2D(widget.viewSize.width / 2, widget.viewSize.height / 2),
          _frontWorld!,
          _camera,
          _light,
          allowUserWorldRotation: false,
          allowUserWorldZoom: false,
          checkTouchObj: false,
          useUserGesture: false,
          vn: _vn,
        ),
      ];
    } else if (widget.backLayerElements.isNotEmpty &&
        widget.frontLayerElements.isEmpty) {
      return [
        Sp3dRenderer(
          widget.viewSize,
          Sp3dV2D(widget.viewSize.width / 2, widget.viewSize.height / 2),
          _backWorld!,
          _camera,
          _light,
          allowUserWorldRotation: false,
          allowUserWorldZoom: false,
          checkTouchObj: false,
          useUserGesture: false,
          vn: _vn,
        ),
        widget.child,
      ];
    } else {
      return [
        Sp3dRenderer(
          widget.viewSize,
          Sp3dV2D(widget.viewSize.width / 2, widget.viewSize.height / 2),
          _backWorld!,
          _camera,
          _light,
          allowUserWorldRotation: false,
          allowUserWorldZoom: false,
          checkTouchObj: false,
          useUserGesture: false,
          vn: _vn,
        ),
        widget.child,
        Sp3dRenderer(
          widget.viewSize,
          Sp3dV2D(widget.viewSize.width / 2, widget.viewSize.height / 2),
          _frontWorld!,
          _camera,
          _light,
          allowUserWorldRotation: false,
          allowUserWorldZoom: false,
          checkTouchObj: false,
          useUserGesture: false,
          vn: _vn,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_backWorldLoaded && _frontWorldLoaded) {
      return Stack(children: _getStackChildren());
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
