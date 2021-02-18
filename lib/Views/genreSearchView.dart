import 'package:flutter/material.dart';
import 'package:AlphaReader/Helper/apiRequests.dart';
import 'mangaView.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GenreSearch extends StatefulWidget {
  final maxPages, genres;
  GenreSearch({this.maxPages, this.genres});
  @override
  _GenreSearchState createState() => _GenreSearchState();
}

class _GenreSearchState extends State<GenreSearch> {
  GenreSearchData gsd = GenreSearchData();
  String font = 'Montserrat';
  String pageNo = '1';
  bool isLoading;
  var data;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    await gsd.getGenreSearchData(widget.genres, pageNo);
    data = gsd.searchPageData;
    gsd.searchPageData = [];

    setState(() {
      isLoading = false;
    });
  }

  getDataOnReload() async {
    await gsd.getGenreSearchData(widget.genres, pageNo);
    data = gsd.searchPageData;
    gsd.searchPageData = [];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        PaintingBinding.instance.imageCache.clear();
        print('cleared genre search view');
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Color(0xff212121),
        ),
        body: isLoading
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.purple[900],
                  ),
                ),
              )
            : gsd.response == null
                ? RefreshIndicator(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: 200,
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
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                          ),
                          itemBuilder: (context, index) {
                            return mangaCard(
                              data[index].image,
                              data[index].title,
                              data[index].mangaUrl,
                              data[index].latestChapter,
                            );
                          },
                          itemCount: data.length,
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton(
                            hint: Text(
                              'Page ' + pageNo,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: font,
                                fontSize: 14,
                              ),
                            ),
                            icon: Icon(Icons.chrome_reader_mode),
                            iconEnabledColor: Colors.purple[900],
                            dropdownColor: Color(0xff212121),
                            items: dropDownList(),
                            onChanged: (val) async {
                              setState(() {
                                pageNo = val.toString();
                              });
                              alertDialog(context, '');
                              await getDataOnReload();
                              Navigator.pop(context);
                              setState(() {});
                            },
                          ),
                        )
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget mangaCard(
      String imageUrl, String title, String mangaUrl, String latestChapter) {
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
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Stack(
          children: <Widget>[
            //Image with the shadermask
            Container(
              width: w / 2.1,
              height: w / 1.4,
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
                  borderRadius: BorderRadius.all(Radius.circular(10)),
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
                height: w / 1.6,
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

  List<DropdownMenuItem> dropDownList() {
    List<DropdownMenuItem> l = [];
    int pages = int.parse(widget.maxPages);
    for (int i = 1; i <= pages; i++) {
      String s = 'Page ' + i.toString();
      l.add(DropdownMenuItem(
        value: i,
        child: Text(
          s,
          style: TextStyle(color: Colors.white),
        ),
      ));
    }
    return l;
  }

  void alertDialog(BuildContext context, String error) {
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
              alignment: Alignment.center,
              height: 100,
              child: error != ''
                  ? Text(
                      error,
                      style: TextStyle(color: Colors.white, fontFamily: font),
                    )
                  : CircularProgressIndicator(
                      backgroundColor: Colors.purple[900],
                    ),
            ),
            actions: <Widget>[
              error == ''
                  ? Container()
                  : FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('ok'),
                    )
            ],
          ),
        );
      },
    );
  }
}
