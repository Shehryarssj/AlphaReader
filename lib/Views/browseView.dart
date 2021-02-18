import 'package:AlphaReader/Views/searchFieldView.dart';
import 'package:flutter/material.dart';
import 'browseGenreView.dart';

class Browse extends StatefulWidget {
  @override
  _BrowseState createState() => _BrowseState();
}

class _BrowseState extends State<Browse> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
                    Icons.format_list_bulleted,
                    size: 18,
                  ),
                  text: 'Genre',
                ),
                Tab(
                  icon: Icon(
                    Icons.search,
                    size: 18,
                  ),
                  text: 'Search',
                )
              ],
              indicatorColor: Colors.purple[900],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            BrowseGenre(),
            SearchFieldView(),
          ],
        ),
      ),
    );
  }
}
