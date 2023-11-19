import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sakura_blizzard/sakura_blizzard.dart';
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

  // Surface image
  List<Uint8List>? _images;

  // Image on the back.
  // Set a horizontally flipped image or set a dedicated back image.
  List<Uint8List>? _imagesR;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<Uint8List> _readFileBytes(String filePath) async {
    ByteData bd = await rootBundle.load(filePath);
    return bd.buffer.asUint8List(bd.offsetInBytes, bd.lengthInBytes);
  }

  /// Here, load the image you want to use in ImageFallView.
  void _loadImage() async {
    final Uint8List img1 =
        await _readFileBytes("./assets/images/your_image1.png");
    final Uint8List img2 =
        await _readFileBytes("./assets/images/your_image2.png");
    final Uint8List img1r =
        await _readFileBytes("./assets/images/your_image1_r.png");
    final Uint8List img2r =
        await _readFileBytes("./assets/images/your_image2_r.png");
    setState(() {
      _images = [img1, img2];
      _imagesR = [img1r, img2r];
    });
  }

  Widget _getView(double w, double h) {
    if (_selectedIndex == 0) {
      return SakuraBlizzardView(
          viewSize: Size(w, h),
          fps: 60,
          child: const Center(
              child: Text(
            "Sakura",
            style: TextStyle(fontSize: 72),
          )));
    } else if (_selectedIndex == 1) {
      return SnowFallView(
          viewSize: Size(w, h),
          fps: 60,
          child: Row(children: [
            Expanded(
                child: Container(
                    color: Colors.blue[300],
                    child: const Center(
                        child: Text(
                      "Snow",
                      style: TextStyle(fontSize: 72),
                    ))))
          ]));
    } else if (_selectedIndex == 2) {
      return ImageFallView(
          viewSize: Size(w, h),
          fps: 60,
          images: _images!,
          backImages: _imagesR!,
          frontObjSize: const VRange(min: 12, max: 48),
          backObjSize: const VRange(min: 12, max: 48),
          child: const Center(
              child: Text(
            "Image",
            style: TextStyle(fontSize: 72),
          )));
    } else {
      return RainFallView(
          viewSize: Size(w, h),
          fps: 60,
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
    if (_images == null || _imagesR == null) {
      return MaterialApp(
          title: 'SakuraBlizzard',
          home: Scaffold(
              appBar: AppBar(
                title: const Text(
                  'SakuraBlizzard',
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.white,
              ),
              backgroundColor: Colors.white,
              body: const Center(child: CircularProgressIndicator())));
    }
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
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.white,
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
                    icon: Icon(Icons.cloudy_snowing), label: "Snow"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.image), label: "Image"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.water_drop), label: "Rain"),
              ],
              type: BottomNavigationBarType.fixed,
            )));
  }
}
