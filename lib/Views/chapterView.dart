import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:AlphaReader/Helper/apiRequests.dart';
import 'package:AlphaReader/Helper/databaseHelper.dart';

class ChapterView extends StatefulWidget {
  final String url, chapterNo, title, mangaUrl, imageUrl;
  final List chapters;
  final int chapterIndex;
  ChapterView(
      {this.url,
      this.chapterNo,
      this.title,
      this.chapters,
      this.chapterIndex,
      this.mangaUrl,
      this.imageUrl});

  @override
  _ChapterViewState createState() => _ChapterViewState();
}

class _ChapterViewState extends State<ChapterView> {
  bool isLoading = false;
  List data, imagesToShow;
  int endIndex, chapterIndex;
  ChapterData cd = ChapterData();
  ScrollController _scrollController = ScrollController();
  String font = "Montserrat", chapterNo, u;

  @override
  void initState() {
    super.initState();
    chapterIndex = widget.chapterIndex;
    chapterNo = widget.chapterNo;
    getData();
    _scrollController.addListener(
      () {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          _addImage();
        }
      },
    );
  }

  Future<void> getData({String url}) async {
    setState(() {
      isLoading = true;
    });

    if (url != null) {
      u = url;
    } else {
      u = widget.url;
    }
    await cd.getChapterData(u);
    data = cd.imageLinks;

    if (data.length > 3) {
      imagesToShow = [data[0], data[1], data[2]];
      endIndex = 3;
    } else {
      imagesToShow = data;
      endIndex = data.length;
    }

    cd.imageLinks = [];

    setState(() {
      isLoading = false;
    });
  }

  getDataOnReload() async {
    await cd.getChapterData(widget.url);
    data = cd.imageLinks;
    if (data.length > 3) {
      imagesToShow = [data[0], data[1], data[2]];
      endIndex = 3;
    } else {
      imagesToShow = data;
      endIndex = data.length;
    }
    cd.imageLinks = [];
  }

//Adds data to image list for lazy load
  _addImage() {
    if (endIndex != data.length) {
      imagesToShow.add(data[endIndex]);
      endIndex = endIndex + 1;
      if (endIndex != data.length) {
        imagesToShow.add(data[endIndex]);
        endIndex = endIndex + 1;
        setState(() {});
      } else {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : (cd.response == null
            ? Scaffold(
                backgroundColor: Color(0xff212121),
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  elevation: 0,
                ),
                body: RefreshIndicator(
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
                    }),
              )
            : WillPopScope(
                onWillPop: () async {
                  PaintingBinding.instance.imageCache.clear();
                  print('cleared chapterview');
                  return true;
                },
                child: Scaffold(
                  backgroundColor: Color(0xff212121),
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(30),
                    child: AppBar(
                      backgroundColor: Colors.black,
                      elevation: 0,
                      leading: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      title: Text(
                        'Chapter ' + chapterNo,
                        style: TextStyle(
                          fontFamily: font,
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      actions: <Widget>[
                        //Chapter Navigation Buttons
                        prevButton(),
                        SizedBox(
                          width: 5,
                        ),
                        nextButton(),
                        SizedBox(
                          width: 20,
                        ),
                        PopupMenuButton<String>(
                          color: Color(0xff212121),
                          onSelected: (value) async {
                            int id;
                            if (value == 'Add To Queue') {
                              bool queued;
                              var res = await DatabaseHelper.instance
                                  .rowQuery(widget.title, 'queue');
                              if (res.length != 0) {
                                queued = true;
                                id = res[0]['id'];
                              } else {
                                queued = false;
                              }
                              if (!queued) {
                                var date = new DateTime.now();
                                String dateAdded = date.year.toString() +
                                    '-' +
                                    date.month.toString() +
                                    '-' +
                                    date.day.toString();

                                await DatabaseHelper.instance.insert({
                                  DatabaseHelper.title: widget.title,
                                  DatabaseHelper.url: widget.mangaUrl,
                                  DatabaseHelper.imageUrl: widget.imageUrl,
                                  DatabaseHelper.dateAdded: dateAdded,
                                  DatabaseHelper.queuedchapterNo: chapterNo,
                                  DatabaseHelper.queuedchapterUrl: u,
                                  DatabaseHelper.queuedchapterIndex:
                                      chapterIndex
                                }, 'queue');
                              } else {
                                alertDialog(
                                    context,
                                    'Already In Queue, Do You Want To Update It?',
                                    id);
                              }
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return {'Download', 'Add To Queue'}
                                .map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(
                                  choice,
                                  style: TextStyle(
                                      fontFamily: font, color: Colors.white),
                                ),
                              );
                            }).toList();
                          },
                        )
                      ],
                    ),
                  ),
                  body: Column(
                    children: <Widget>[
                      //Chapter Images
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: imagesToShow.length,
                          itemBuilder: (context, index) {
                            var arr = imagesToShow[index].split('');
                            var x = arr[10];
                            try {
                              int.parse(x);
                              var link = '';
                              arr.removeAt(10);
                              for (var letter in arr) {
                                link += letter;
                              }
                              data[index] = link;
                            } catch (e) {
                              //print('cloud flare XD');
                            }
                            return Container(
                              padding:
                                  EdgeInsets.only(top: 10, left: 5, right: 5),
                              child: Column(
                                children: <Widget>[
                                  CachedNetworkImage(
                                    fadeInCurve: Curves.easeIn,
                                    fadeInDuration: Duration(milliseconds: 500),
                                    imageUrl: data[index],
                                    placeholder: (context, url) => Container(
                                        height: 100,
                                        child: Center(
                                            child:
                                                CircularProgressIndicator())),
                                  ),
                                  Text(
                                    'Page ${index + 1} / ${data.length}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ));
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
                  Navigator.of(context).pop();
                },
                child: Text(
                  'No',
                  style:
                      TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                )),
            FlatButton(
              onPressed: () async {
                var date = new DateTime.now();
                String dateAdded = date.year.toString() +
                    '-' +
                    date.month.toString() +
                    '-' +
                    date.day.toString();

                await DatabaseHelper.instance.update(
                  id,
                  'queue',
                  widget.title,
                  widget.mangaUrl,
                  widget.imageUrl,
                  dateAdded,
                  chapterNo,
                  u,
                  chapterIndex,
                );
                Navigator.pop(context);
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

  Widget prevButton() {
    return ButtonTheme(
      minWidth: 30,
      child: RaisedButton(
        onPressed: chapterIndex == 0
            ? null
            : () async {
                chapterIndex -= 1;
                //Since the list of chapters starts from latest chapter we need to reverse the index to get the desired chapter
                String url =
                    widget.chapters[widget.chapters.length - 1 - chapterIndex];
                chapterNo = url.split('_').last;
                getData(url: url);
              },
        color: Color(0xff191919),
        child: Text(
          'Prev',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget nextButton() {
    return ButtonTheme(
      minWidth: 30,
      child: RaisedButton(
        color: Color(0xff191919),
        onPressed: (chapterIndex == widget.chapters.length - 1)
            ? null
            : () async {
                chapterIndex += 1;
                String url =
                    widget.chapters[widget.chapters.length - 1 - chapterIndex];
                chapterNo = url.split('_').last;

                getData(url: url);
              },
        child: Text(
          'Next',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
