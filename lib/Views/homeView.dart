import 'package:AlphaReader/Views/favouritesView.dart';
import 'package:AlphaReader/Views/queueView.dart';
import 'package:flutter/material.dart';
import 'updatesView.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: AppBar(
            backgroundColor: Color(0xff212121),
            centerTitle: true,
            title: Image.asset(
              'assets/images/logo.jpg',
              height: 15,
            ),
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.new_releases,
                    size: 18,
                  ),
                  text: 'Updates',
                ),
                Tab(
                  icon: Icon(
                    Icons.queue,
                    size: 18,
                  ),
                  text: 'Queue',
                ),
                Tab(
                  icon: Icon(
                    Icons.favorite,
                    size: 18,
                  ),
                  text: 'Favourites',
                )
              ],
              indicatorColor: Colors.purple[900],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            Updates(),
            QueueView(),
            FavouritesView(),
          ],
        ),
      ),
    );
  }
}
