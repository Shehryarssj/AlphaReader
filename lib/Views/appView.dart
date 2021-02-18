import 'package:AlphaReader/Views/browseView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'homeView.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String font = 'Montserrat';
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: IndexedStack(
          index: _currentIndex,
          children: <Widget>[Home(), Browse()],
        ),
        bottomNavigationBar: Container(
          height: 60,
          color: Colors.black,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(20)),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.shifting,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white30,
              currentIndex: _currentIndex,
              onTap: (val) {
                if (val != _currentIndex) {
                  setState(() {
                    _currentIndex = val;
                  });
                }
              },
              items: [
                BottomNavigationBarItem(
                  backgroundColor: Colors.purple[900],
                  icon: Icon(Icons.home),
                  title: Text(
                    'Home',
                    style: TextStyle(fontFamily: font, fontSize: 12),
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  title: Text(
                    'Browse',
                    style: TextStyle(fontFamily: font, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
