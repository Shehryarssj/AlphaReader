import 'dart:ui';
import 'package:AlphaReader/Views/chapterView2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../Helper/apiRequests.dart';
import '../Helper/databaseHelper.dart';

class MangaView extends StatefulWidget {
  final mangaUrl, imageUrl;
  MangaView({this.mangaUrl, this.imageUrl});
  @override
  _MangaViewState createState() => _MangaViewState();
}

class _MangaViewState extends State<MangaView> {
  String authors;
  String genres;
  String font = 'Montserrat';
  int favId, queueId;
  bool isLoading = false, showMore = false, favourited, queued;
  var data;
  MangaData md = MangaData();
  var w;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    await md.getMangaData(widget.mangaUrl);
    data = md.mangaData;
    await getQueued();
    await getFavorited();
    if (md.response != null) {
      authors = data.authors.join(', ');

      genres = data.genres.join(',\n');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> getQueued() async {
    var res2 = await DatabaseHelper.instance.rowQuery(data.title, 'queue');
    if (res2.length != 0) {
      queued = true;
      queueId = res2[0]['id'];
    } else {
      queued = false;
    }
  }

  Future<void> getFavorited() async {
    var res1 = await DatabaseHelper.instance.rowQuery(data.title, 'favourites');
    if (res1.length != 0) {
      favourited = true;
      favId = res1[0]['id'];
    } else {
      favourited = false;
    }
  }

  getDataOnReload() async {
    await md.getMangaData(widget.mangaUrl);
    data = md.mangaData;
    if (md.response != null) {
      authors = data.authors.join(',\n');
      genres = data.genres.join(',\n');
      var res1 =
          await DatabaseHelper.instance.rowQuery(data.title, 'favourites');
      var res2 = await DatabaseHelper.instance.rowQuery(data.title, 'queue');
      if (res1.length != 0) {
        favourited = true;
        favId = res1[0]['id'];
      } else {
        favourited = false;
      }
      if (res2.length != 0) {
        queued = true;
        queueId = res2[0]['id'];
      } else {
        queued = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    return isLoading
        ? Container(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.purple[900],
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Color(0xff212121),
            appBar: AppBar(
              backgroundColor: Color(0xff212121),
              elevation: 0,
            ),
            body: md.response == null
                ? RefreshIndicator(
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: 200,
                        child: Center(
                          child: Text(
                            'Network Error',
                            style: TextStyle(
                                fontFamily: font,
                                fontSize: 16,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    onRefresh: () async {
                      await getDataOnReload();
                      setState(() {});
                    })
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      //Stack contains the manga image and info
                      Stack(
                        children: <Widget>[
                          //Background image
                          Container(
                            width: w,
                            height: w / 1.7,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: CachedNetworkImage(
                                imageUrl: widget.imageUrl,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.purple[900],
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          ),
                          //Black filter for bacckground image
                          Container(
                            width: w,
                            height: w / 1.7,
                            color: Colors.black38,
                          ),
                          //Blur filter for background image
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              width: w,
                              height: w / 1.7,
                              color: Colors.black12,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              //Title
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  data.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: font,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              //Manga Info
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    //Manga Image
                                    Container(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          width: w / 2.5,
                                          imageUrl: widget.imageUrl,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          //Status
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                'Status: ',
                                                style: TextStyle(
                                                    fontFamily: font,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14),
                                              ),
                                              Text(
                                                data.status,
                                                style: TextStyle(
                                                  fontFamily: font,
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          //Last Updated
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                'Updated ',
                                                style: TextStyle(
                                                    fontFamily: font,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14),
                                              ),
                                              Text(
                                                data.lastUpdated,
                                                style: TextStyle(
                                                  fontFamily: font,
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          //Authors
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'Author(s): ',
                                                style: TextStyle(
                                                    fontFamily: font,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14),
                                              ),
                                              Container(
                                                width: 100,
                                                child: Text(
                                                  authors,
                                                  overflow:
                                                      TextOverflow.visible,
                                                  style: TextStyle(
                                                    fontFamily: font,
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          //Genres
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'Genre(s): ',
                                                style: TextStyle(
                                                    fontFamily: font,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14),
                                              ),
                                              Text(
                                                genres,
                                                style: TextStyle(
                                                  fontFamily: font,
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 55, top: 5),
                                child: Row(
                                  children: <Widget>[
                                    GestureDetector(
                                      child: Icon(
                                        favourited
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 30,
                                        color: favourited
                                            ? Colors.red
                                            : Colors.white,
                                      ),
                                      onTap: () async {
                                        var date = new DateTime.now();
                                        String dateAdded =
                                            date.year.toString() +
                                                '-' +
                                                date.month.toString() +
                                                '-' +
                                                date.day.toString();

                                        if (!favourited) {
                                          await DatabaseHelper.instance.insert({
                                            DatabaseHelper.title: data.title,
                                            DatabaseHelper.url: widget.mangaUrl,
                                            DatabaseHelper.imageUrl:
                                                widget.imageUrl,
                                            DatabaseHelper.dateAdded: dateAdded,
                                            DatabaseHelper.latestchapterNo:
                                                data.chapters[0].split('_').last
                                          }, 'favourites');
                                          await getFavorited();

                                          setState(() {
                                            favourited = true;
                                          });
                                        } else {
                                          alertDialog(
                                              context,
                                              'Remove From Favorites?',
                                              favId,
                                              'favourites');
                                        }
                                      },
                                    ),
                                    SizedBox(
                                      width: 25,
                                    ),
                                    GestureDetector(
                                      child: Icon(
                                        Icons.add_circle,
                                        color: !queued
                                            ? Colors.white
                                            : Colors.blue,
                                        size: 30,
                                      ),
                                      onTap: () async {
                                        var date = new DateTime.now();
                                        String dateAdded =
                                            date.year.toString() +
                                                '-' +
                                                date.month.toString() +
                                                '-' +
                                                date.day.toString();

                                        if (!queued) {
                                          var arr =
                                              data.chapters.last.split('_');

                                          await DatabaseHelper.instance.insert({
                                            DatabaseHelper.title: data.title,
                                            DatabaseHelper.url: widget.mangaUrl,
                                            DatabaseHelper.imageUrl:
                                                widget.imageUrl,
                                            DatabaseHelper.dateAdded: dateAdded,
                                            DatabaseHelper.queuedchapterNo:
                                                arr.last,
                                            DatabaseHelper.queuedchapterUrl:
                                                data.chapters.last,
                                            DatabaseHelper.queuedchapterIndex: 0
                                          }, 'queue');
                                          await getQueued();
                                          setState(() {
                                            queued = true;
                                          });
                                        } else {
                                          alertDialog(
                                              context,
                                              'Remove From Reading Queue?',
                                              queueId,
                                              'queue');
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Colors.deepPurple[900],
                                    ),
                                    Text(
                                      'Description',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: font,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        data.description,
                                        maxLines: showMore ? 100 : 3,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: font,
                                          fontSize: 12,
                                        ),
                                      ),
                                      GestureDetector(
                                        child: Text(
                                          (showMore
                                              ? 'Show Less'
                                              : 'Show More'),
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontFamily: font,
                                              fontSize: 12),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            showMore = !showMore;
                                          });
                                        },
                                      ),
                                    ],
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Colors.deepPurple[900],
                                    ),
                                    Text(
                                      'Chapters',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: font,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              GridView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        childAspectRatio: 1.9,
                                        crossAxisCount: 5),
                                itemBuilder: (context, index) {
                                  var arr = data.chapters[index].split('_');
                                  return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChapterView(
                                              url: data.chapters[index],
                                              title: data.title,
                                              imageUrl: widget.imageUrl,
                                              mangaUrl: widget.mangaUrl,
                                              chapterNo: arr.last,
                                              chapters: data.chapters,
                                              chapterIndex:
                                                  data.chapters.length -
                                                      1 -
                                                      index,
                                            ),
                                          ),
                                        );
                                      },
                                      child: chapterTile(
                                          arr.last, data.chapters[index]));
                                },
                                itemCount: data.chapters.length,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
          );
  }

  Widget chapterTile(String chapter, String url) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.purple[900],
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        'Ch. ' + chapter,
        style: TextStyle(fontSize: 10, color: Colors.white, fontFamily: font),
      ),
    );
  }

  void alertDialog(BuildContext context, String t, int id, String table) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xff212121),
          content: Container(
            alignment: Alignment.center,
            height: 100,
            child: Text(
              t,
              style: TextStyle(
                  fontSize: 16, color: Colors.white, fontFamily: 'Montserrat'),
            ),
          ),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  setState(() {});
                  Navigator.of(context).pop();
                },
                child: Text(
                  'No',
                  style:
                      TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                )),
            FlatButton(
              onPressed: () async {
                await DatabaseHelper.instance.delete(id, table);
                setState(() {
                  table == 'favourites' ? favourited = false : queued = false;
                });
                Navigator.of(context).pop();
              },
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
              ),
            )
          ],
        );
      },
    );
  }
}
