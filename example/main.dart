import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sakura_blizzard/sakura_blizzard.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:util_simple_3d/util_simple_3d.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<String> assetPaths = [
    "./assets/images/your_image1.png",
    "./assets/images/your_image2.png",
    "./assets/images/your_image3.png",
  ];

  final List<String> backAssetPaths = [
    "./assets/images/your_image1_r.png",
    "./assets/images/your_image2_r.png",
    "./assets/images/your_image3_r.png",
  ];

  Widget _getView(double w, double h) {
    const fps = 60;
    if (_selectedIndex == 0) {
      return SakuraBlizzardView(
          viewSize: Size(w, h),
          fps: fps,
          child: const Center(
              child: Text(
            "Sakura",
            style: TextStyle(fontSize: 72),
          )));
    } else if (_selectedIndex == 1) {
      final random = Random();
      return CustomFallView(
        viewSize: Size(w, h),
        fps: fps,
        objCreation: (isFront, viewSize) {
          final double size = 8 + random.nextDouble() * 16;
          final Sp3dObj r =
              UtilSakuraCreator.sakuraPetal(size / 1.5, size, size / 6);
          r.physics = DirectionalConfettiHirahiraPhysics(
            Size(w, h),
            // Upward direction, strength 25
            direction: Sp3dV3D(0, 25, 0),
            // Diffuses in a 60-degree sector shape
            spreadAngle: pi / 3,
            maxBurstFrames: 180,
            transitionFrames: 174,
            speedVariance: 15.0,
            gravity: 0.15,
            damping: 0.98,
            fps: fps,
          );
          // Make all objects pop out from the center of the screen.
          r.move(Sp3dV3D(viewSize.width / 2, viewSize.height / 2, 0));
          return r;
        },
        enablePositionReset: false,
        child: const Center(
            child: Text(
          "Sakura Pop",
          style: TextStyle(fontSize: 72),
        )),
      );
    } else if (_selectedIndex == 2) {
      return AssetImageFallView(
        viewSize: Size(w, h),
        fps: fps,
        assetPaths: assetPaths,
        backAssetPaths: backAssetPaths,
        showIndicatorOnLoading: false,
        child: const Center(
          child: Text("Image", style: TextStyle(fontSize: 72)),
        ),
      );
    } else if (_selectedIndex == 3) {
      return CustomImageFallView(
        viewSize: Size(w, h),
        fps: fps,
        assetPaths: assetPaths,
        backAssetPaths: backAssetPaths,
        showIndicatorOnLoading: false,
        physicsCreation: () => PopPhysics(minBurstSpeed: 10, maxBurstSpeed: 36),
        positionCreation: (b, size) =>
            Sp3dV3D(size.width / 2, size.height / 2, 0),
        sizeCreation: (b) => const VRange(min: 8, max: 32).getRandomInRange(),
        enablePositionReset: false,
        child: const Center(
            child: Text(
          "Image Pop",
          style: TextStyle(fontSize: 72),
        )),
      );
    } else {
      return RainFallView(
          viewSize: Size(w, h),
          fps: fps,
          child: Row(children: [
            Expanded(
                child: Container(
                    color: Colors.black,
                    child: const Center(
                        child: Text(
                      "Rain",
                      style: TextStyle(fontSize: 72, color: Colors.white),
                    ))))
          ]));
    }
  }

  void _bottomBarCallback(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        kBottomNavigationBarHeight -
        kToolbarHeight;
    return MaterialApp(
        title: 'SakuraBlizzard',
        home: Scaffold(
            appBar: AppBar(
              title: const Text(
                'SakuraBlizzard',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.pinkAccent[100],
            ),
            backgroundColor: Colors.white,
            body: _getView(w, h),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _bottomBarCallback,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.yard), label: "Sakura"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.yard), label: "Sakura Pop"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.image), label: "Image"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.image), label: "Image Pop"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.water_drop), label: "Rain"),
              ],
              type: BottomNavigationBarType.fixed,
            )));
  }
}
