import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter/material.dart';
import 'package:AlphaReader/Helper/apiRequests.dart';
import 'package:AlphaReader/Helper/databaseHelper.dart';
import 'package:photo_view/photo_view.dart';
import 'package:AlphaReader/Helper/downloadHelper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  ScrollController _scrollController = ScrollController();
  FlutterLocalNotificationsPlugin fltrNotification;
  ChapterData cd = ChapterData();
  bool isLoading = false, webToonView = false;
  List data, imagesToShow;
  int chapterIndex, endIndex;
  String font = "Montserrat", chapterNo, u;

  @override
  void initState() {
    super.initState();
    var androidInitilize = new AndroidInitializationSettings('app_icon');
    var iOSinitilize = new IOSInitializationSettings();
    var initilizationsSettings =
        new InitializationSettings(androidInitilize, iOSinitilize);
    fltrNotification = new FlutterLocalNotificationsPlugin();
    fltrNotification.initialize(initilizationsSettings,
        onSelectNotification: null);
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

  Future _showNotification(String message) async {
    var androidDetails = new AndroidNotificationDetails(
        "Channel ID", "Desi programmer", "This is my channel",
        importance: Importance.Max, autoCancel: false);
    var iSODetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(androidDetails, iSODetails);

    await fltrNotification.show(
        0, "Download", message, generalNotificationDetails,
        payload: "Task");
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
    print(data[0]);
    cleanImageUrls();
    cd.imageLinks = [];
    if (data.length > 3) {
      imagesToShow = [data[0], data[1], data[2]];
      endIndex = 3;
    } else {
      imagesToShow = data;
      endIndex = data.length;
    }

    setState(() {
      isLoading = false;
    });
  }

  getDataOnReload() async {
    await cd.getChapterData(widget.url);
    data = cd.imageLinks;
    cleanImageUrls();
    cd.imageLinks = [];
    if (data.length > 3) {
      imagesToShow = [data[0], data[1], data[2]];
      endIndex = 3;
    } else {
      imagesToShow = data;
      endIndex = data.length;
    }
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
              child: CircularProgressIndicator(
                backgroundColor: Colors.purple[900],
              ),
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
                        nextButton(),

                        PopupMenuButton<String>(
                          color: Color(0xff212121),
                          itemBuilder: (BuildContext context) {
                            return {
                              'Download',
                              'Add To Queue',
                              'Change Reader View'
                            }.map((String choice) {
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
                          onSelected: (value) async {
                            if (value == 'Add To Queue') {
                              addToQueue();
                            } else if (value == 'Change Reader View') {
                              setState(() {
                                webToonView = !webToonView;
                              });
                            } else {
                              await Permission.storage.request();
                              if (await Permission.storage.status.isGranted) {
                                int i = 0;
                                alertDialogDownload(
                                    context: context, t: 'Downloading');
                                try {
                                  for (var item in data) {
                                    await findPath(item, i.toString(),
                                        widget.title, chapterNo);
                                    i += 1;
                                  }
                                  Navigator.pop(context);
                                  alertDialog(
                                      context: context,
                                      t: 'Downloaded to Alpha Reader Folder');
                                } catch (e) {
                                  Navigator.pop(context);
                                  _showNotification('Download Failed');
                                  debugPrint(e);
                                }
                              }
                            }
                          },
                        )
                      ],
                    ),
                  ),
                  body: webToonView
                      ? Column(
                          children: <Widget>[
                            //Chapter Images
                            Expanded(
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: imagesToShow.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: EdgeInsets.only(
                                        top: 10, left: 5, right: 5),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: CachedNetworkImage(
                                            httpHeaders: {
                                              "User-Agent":
                                                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 Edge/18.18362',
                                              '__cfduid':
                                                  'db67a11fc6817eec23191e6892c49fcba1595075306'
                                            },
                                            width: 350,
                                            fadeInCurve: Curves.easeIn,
                                            fadeInDuration:
                                                Duration(milliseconds: 500),
                                            imageUrl: imagesToShow[index],
                                            fit: BoxFit.fitWidth,
                                            placeholder: (context, url) =>
                                                Container(
                                              height: 400,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  backgroundColor:
                                                      Colors.purple[900],
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
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
                        )
                      : Swiper(
                          loop: false,
                          itemCount: data.length,
                          fade: 0.0,
                          duration: 0,
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              width: 350,
                              imageUrl: data[index],
                              imageBuilder: (context, imageProvider) =>
                                  PhotoView(
                                imageProvider: imageProvider,
                              ),
                              placeholder: (context, url) => Container(
                                color: Colors.black,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.purple[900],
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            );
                          },
                          pagination: FractionPaginationBuilder(),
                        ),
                ),
              ));
  }

  void alertDialog({BuildContext context, String t, int id}) {
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
          actions: id == null
              ? null
              : <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'No',
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Montserrat'),
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
                      style: TextStyle(
                          color: Colors.white, fontFamily: 'Montserrat'),
                    ),
                  )
                ],
        );
      },
    );
  }

  void alertDialogDownload({BuildContext context, String t}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(
            backgroundColor: Color(0xff212121),
            content: Container(
              alignment: Alignment.center,
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    t,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'Montserrat'),
                  ),
                  CircularProgressIndicator(
                    backgroundColor: Colors.purple[900],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget prevButton() {
    return Container(
      margin: EdgeInsets.only(right: 10),
      child: ButtonTheme(
        minWidth: 20,
        child: RaisedButton(
          color: Color(0xff191919),
          onPressed: chapterIndex == 0
              ? null
              : () async {
                  chapterIndex -= 1;
                  //Since the list of chapters starts from latest chapter we need to reverse the index to get the desired chapter
                  String url = widget
                      .chapters[widget.chapters.length - 1 - chapterIndex];
                  chapterNo = url.split('_').last;
                  PaintingBinding.instance.imageCache.clear();
                  getData(url: url);
                },
          child: Text(
            'Prev',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }

  Widget nextButton() {
    return Container(
      margin: EdgeInsets.only(right: 10),
      child: ButtonTheme(
        minWidth: 20,
        child: RaisedButton(
          color: Color(0xff191919),
          onPressed: (chapterIndex == widget.chapters.length - 1)
              ? null
              : () async {
                  chapterIndex += 1;
                  String url = widget
                      .chapters[widget.chapters.length - 1 - chapterIndex];
                  chapterNo = url.split('_').last;
                  PaintingBinding.instance.imageCache.clear();
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
      ),
    );
  }

  void addToQueue() async {
    int id;
    bool queued;
    var res = await DatabaseHelper.instance.rowQuery(widget.title, 'queue');
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
        DatabaseHelper.queuedchapterIndex: chapterIndex
      }, 'queue');
    } else {
      alertDialog(
          context: context,
          t: 'Already In Queue, Do You Want To Update It?',
          id: id);
    }
  }

  void cleanImageUrls() {
    for (int i = 0; i < data.length; i++) {
      var arr = data[i].split('');
      var x = arr[10];
      try {
        int.parse(x);
        var link = '';
        arr.removeAt(10);
        link = arr.join();
        data[i] = link;
      } catch (e) {
        //print('cloud flare XD');
      }
    }
  }
}
