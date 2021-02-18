import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Helper/apiRequests.dart';
import 'mangaView.dart';

class Updates extends StatefulWidget {
  @override
  _UpdatesState createState() => _UpdatesState();
}

class _UpdatesState extends State<Updates> with AutomaticKeepAliveClientMixin {
  String font = 'Montserrat';
  var h, w;

  var updatesData, topWeeklyData;
  bool isLoading = false;
  MainPageData mpData = MainPageData();

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    await mpData.getMainPageData();
    updatesData = mpData.updatesData;
    mpData.updatesData = [];
    topWeeklyData = mpData.topWeeklyData;
    mpData.topWeeklyData = [];
    setState(() {
      isLoading = false;
    });
  }

  getDataOnReload() async {
    await mpData.getMainPageData();
    updatesData = mpData.updatesData;
    mpData.updatesData = [];
    topWeeklyData = mpData.topWeeklyData;
    mpData.topWeeklyData = [];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    h = MediaQuery.of(context).size.height;
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
        : mpData.response == null
            ? RefreshIndicator(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: 600,
                    color: Colors.black,
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
            : RefreshIndicator(
                onRefresh: () async {
                  await getDataOnReload();
                  setState(() {});
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    color: Colors.black,
                    child: Column(
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            titleRow('Latest'),
                            Container(
                              height: w / 1.6,
                              width: w,
                              decoration: BoxDecoration(),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: updatesData.length,
                                itemBuilder: (context, index) {
                                  return mangaTile(
                                    updatesData[index].title,
                                    updatesData[index].latestChapter,
                                    updatesData[index].image,
                                    updatesData[index].mangaUrl,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            titleRow('Top Weekly'),
                            Container(
                              height: w / 1.6,
                              width: w,
                              decoration: BoxDecoration(),
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: topWeeklyData.length,
                                  itemBuilder: (context, index) {
                                    return mangaTile(
                                      topWeeklyData[index].title,
                                      topWeeklyData[index].latestChapter,
                                      topWeeklyData[index].image,
                                      topWeeklyData[index].mangaUrl,
                                    );
                                  }),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
  }

  Widget mangaTile(
      String title, String latestChapter, String imageUrl, String mangaUrl) {
    var w = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaView(
              mangaUrl: mangaUrl,
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: 10, left: 15),
        child: Stack(
          children: <Widget>[
            //Image with the shadermask
            Container(
              width: w / 2.3,
              height: w / 1.6,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black
                    ],
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                },
                blendMode: BlendMode.dstOut,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      //topRight: Radius.circular(10),
                      topLeft: Radius.circular(15)),
                  child: CachedNetworkImage(
                    width: w / 2.3,
                    height: w / 1.6,
                    imageUrl: imageUrl,
                    fadeInCurve: Curves.easeIn,
                    fadeInDuration: Duration(milliseconds: 500),
                    fit: BoxFit.fill,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.purple[900],
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ),

            //Text on the image
            Container(
                padding: EdgeInsets.only(left: 5),
                alignment: Alignment.bottomLeft,
                width: w / 2.3,
                height: w / 1.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 4,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Chapter " + latestChapter,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget titleRow(String t) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff212121),
            Color(0xff101010),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
        border: Border.all(
          color: Color(0xff212121),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.keyboard_arrow_right,
            color: Colors.purple[900],
          ),
          Text(
            t,
            style:
                TextStyle(color: Colors.white, fontFamily: font, fontSize: 18),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
