import 'package:flutter/material.dart';
import 'package:sakura_blizzard/sakura_blizzard.dart';

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
    } else {
      return ColorfulCubeView(
          viewSize: Size(w, h),
          fps: 60,
          child: const Center(
              child: Text(
            "Cube",
            style: TextStyle(fontSize: 72),
          )));
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
                    icon: Icon(Icons.widgets), label: "Cube"),
              ],
              type: BottomNavigationBarType.fixed,
            )));
  }
}
