import 'package:AlphaReader/Helper/databaseHelper.dart';
import 'package:AlphaReader/Views/chapterView.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'mangaView.dart';
import 'package:AlphaReader/Helper/apiRequests.dart';

class QueueView extends StatefulWidget {
  @override
  _QueueViewState createState() => _QueueViewState();
}

class _QueueViewState extends State<QueueView> {
  var data, count = 0;
  String font = 'Montserrat';
  getData() async {
    try {
      data = await DatabaseHelper.instance.queryAll('queue');
    } catch (e) {
      print(e);
    }
    try {
      count = data.length;
    } catch (e) {
      print('exeption here');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            height: MediaQuery.of(context).size.height - 136,
            color: Colors.black,
            child: count == 0
                ? Center(
                    child: Text(
                      'Pretty Much Empty',
                      style: TextStyle(color: Colors.white, fontFamily: font),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: count,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Color(0xff212121),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MangaView(
                                      mangaUrl: data[index]['url'],
                                      imageUrl: data[index]['imageUrl'],
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: data[index]['imageUrl'],
                                  width: MediaQuery.of(context).size.width / 5,
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
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 1.9,
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      data[index]['title'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: font,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  ),
                                  Text(
                                    'Added: ${data[index]['dateAdded']}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: font,
                                        fontSize: 12),
                                  ),
                                  Text(
                                    'Queued: Chapter ${data[index]['queuedchapterNo']}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: font,
                                        fontSize: 12),
                                  ),
                                  SizedBox(
                                    height: 20, //make button small as possible
                                  ),
                                  ButtonTheme(
                                    minWidth: 20,
                                    child: RaisedButton(
                                      color: Colors.purple[900],
                                      onPressed: () async {
                                        MangaData md = MangaData();
                                        loadingAlertDialog(context);
                                        await md
                                            .getMangaData(data[index]['url']);
                                        Navigator.of(context).pop();
                                        if (md.response != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ChapterView(
                                                chapterIndex: data[index]
                                                    ['queuedchapterIndex'],
                                                chapterNo: data[index]
                                                    ['queuedchapterNo'],
                                                title: data[index]['title'],
                                                url: data[index]
                                                    ['queuedchapterUrl'],
                                                chapters: md.mangaData.chapters,
                                                imageUrl: data[index]
                                                    ['imageUrl'],
                                                mangaUrl: data[index]['url'],
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          side:
                                              BorderSide(color: Colors.white)),
                                      child: Text(
                                        'Resume',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: font,
                                            fontSize: 12),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              onPressed: () {
                                alertDialog(context, 'Remove From Queue?',
                                    data[index]['id']);
                              },
                            )
                          ],
                        ),
                      );
                    },
                  ),
          );
        } else {
          return Container(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.purple[900],
                ),
              ));
        }
      },
    );
  }

  void alertDialog(BuildContext context, String t, int id) {
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
                await DatabaseHelper.instance.delete(id, 'queue');
                setState(() {});
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

  void loadingAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: AlertDialog(
            backgroundColor: Color(0xff212121),
            content: Container(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.purple[900],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
