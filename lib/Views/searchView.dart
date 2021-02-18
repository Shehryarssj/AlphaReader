// import 'package:flutter/material.dart';
// import 'package:AlphaReader/Helper/apiRequests.dart';
// import 'mangaView.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class Search extends StatefulWidget {
//   @override
//   _SearchState createState() => _SearchState();
// }

// class _SearchState extends State<Search> {
//   String font = 'Montserrat';
//   final _formKey = GlobalKey<FormState>();
//   String query = '', textInTextfield = '';
//   String maxPages = '0';
//   String pageNo = '';
//   var data, w;

//   MaxPages mp = MaxPages();
//   SearchData sd = SearchData();

//   @override
//   Widget build(BuildContext context) {
//     w = MediaQuery.of(context).size.width;
//     return SingleChildScrollView(
//       child: Column(
//         //crossAxisAlignment: CrossAxisAlignment.center,
//         children: <Widget>[
//           Form(
//             key: _formKey,
//             child: Container(
//               margin: EdgeInsets.only(top: 15),
//               height: 40,
//               width: w - 100,
//               child: getTextFormField(context),
//             ),
//           ),
//           data == null
//               ? Container()
//               : Padding(
//                   padding: const EdgeInsets.only(top: 10),
//                   child: GridView.builder(
//                     physics: NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       childAspectRatio: 0.7,
//                     ),
//                     itemBuilder: (context, index) {
//                       return mangaCard(data[index].image, data[index].title,
//                           data[index].mangaUrl, data[index].latestChapter);
//                     },
//                     itemCount: data.length,
//                   ),
//                 ),
//           DropdownButtonHideUnderline(
//             child: DropdownButton(
//               hint: Text(
//                 'Page ' + pageNo,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontFamily: font,
//                   fontSize: 14,
//                 ),
//               ),
//               icon: Icon(Icons.chrome_reader_mode),
//               iconEnabledColor: Colors.purple[900],
//               dropdownColor: Color(0xff212121),
//               items: dropDownList(),
//               onChanged: (val) async {
//                 setState(() {
//                   pageNo = val.toString();
//                 });
//                 alertDialog(context, '');

//                 await sd.getSearchData(query, pageNo);
//                 Navigator.pop(context);
//                 if (sd.response != null) {
//                   setState(() {
//                     data = sd.searchPageData;
//                     sd.searchPageData = [];
//                   });
//                 } else {
//                   alertDialog(context, 'Network Error');
//                 }
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget getTextFormField(BuildContext context) {
//     return TextFormField(
//       textInputAction: TextInputAction.search,
//       cursorColor: Colors.grey,
//       decoration: InputDecoration(
//         hintText: 'Enter Manga Name',
//         enabledBorder: UnderlineInputBorder(
//             borderSide: BorderSide(color: Colors.purple[900])),
//         focusedBorder: UnderlineInputBorder(
//           borderSide: BorderSide(color: Colors.purple[900]),
//         ),
//         hintStyle: TextStyle(
//             color: Colors.grey,
//             fontFamily: font,
//             fontSize: 14,
//             fontWeight: FontWeight.bold),
//       ),
//       style: TextStyle(
//         color: Colors.white,
//         fontFamily: font,
//         fontSize: 14,
//         fontWeight: FontWeight.bold,
//       ),
//       onChanged: (value) {
//         textInTextfield = value;
//       },
//       validator: (value) {
//         return value.length > 2 ? null : "Enter Three Characters Or More";
//       },
//       onFieldSubmitted: (value) async {
//         if (_formKey.currentState.validate()) {
//           alertDialog(context, '');
//           await mp.getMaxPagesSearch(value);
//           Navigator.pop(context);
//           if (mp.response != null) {
//             if (mp.maxPages != '0') {
//               setState(() {
//                 maxPages = mp.maxPages;
//                 pageNo = '1';
//               });
//               await sd.getSearchData(textInTextfield, pageNo);
//               if (sd.response != null) {
//                 setState(() {
//                   data = sd.searchPageData;
//                   sd.searchPageData = [];
//                   query = value;
//                 });
//               } else {
//                 alertDialog(context, 'Network Error');
//               }
//             } else {
//               alertDialog(context, 'No Results');
//             }
//           } else {
//             alertDialog(context, 'Network Error');
//           }
//         }
//       },
//     );
//   }

//   void alertDialog(BuildContext context, String error) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return WillPopScope(
//           onWillPop: () {},
//           child: AlertDialog(
//             backgroundColor: Color(0xff212121),
//             content: Container(
//               alignment: Alignment.center,
//               height: 100,
//               child: error != ''
//                   ? Text(
//                       error,
//                       style: TextStyle(color: Colors.white, fontFamily: font),
//                     )
//                   : CircularProgressIndicator(),
//             ),
//             actions: <Widget>[
//               error == ''
//                   ? Container()
//                   : FlatButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: Text('ok'),
//                     )
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget mangaCard(
//       String imageUrl, String title, String mangaUrl, String latestChapter) {
//     var w = MediaQuery.of(context).size.width;
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => MangaView(
//               mangaUrl: mangaUrl,
//               imageUrl: imageUrl,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         alignment: Alignment.center,
//         margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//         child: Stack(
//           children: <Widget>[
//             //Image with the shadermask
//             Container(
//               width: w / 2.1,
//               height: w / 1.4,
//               child: ShaderMask(
//                 shaderCallback: (rect) {
//                   return LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.transparent,
//                       Colors.transparent,
//                       Colors.black
//                     ],
//                   ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
//                 },
//                 blendMode: BlendMode.dstOut,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.all(Radius.circular(10)),
//                   child: CachedNetworkImage(
//                     width: w / 2.3,
//                     height: w / 1.6,
//                     imageUrl: imageUrl,
//                     fadeInCurve: Curves.easeIn,
//                     fadeInDuration: Duration(milliseconds: 500),
//                     fit: BoxFit.fill,
//                     errorWidget: (context, url, error) => Container(
//                       height: 100,
//                       decoration: BoxDecoration(
//                           border: Border.all(color: Colors.white)),
//                       child: Center(
//                         child: Text(
//                           'Network Error',
//                           style:
//                               TextStyle(fontFamily: font, color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             //Text on the image
//             Container(
//                 padding: EdgeInsets.only(left: 5),
//                 alignment: Alignment.bottomLeft,
//                 width: w / 2.3,
//                 height: w / 1.6,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: <Widget>[
//                     Text(
//                       title,
//                       maxLines: 4,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontFamily: 'Montserrat',
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       "Chapter " + latestChapter,
//                       style: TextStyle(
//                         color: Colors.grey,
//                         fontSize: 11,
//                         fontFamily: 'Montserrat',
//                         fontWeight: FontWeight.bold,
//                       ),
//                     )
//                   ],
//                 ))
//           ],
//         ),
//       ),
//     );
//   }

//   List<DropdownMenuItem> dropDownList() {
//     List<DropdownMenuItem> l = [];
//     int pages = int.parse(maxPages);
//     for (int i = 1; i <= pages; i++) {
//       String s = 'Page ' + i.toString();
//       l.add(DropdownMenuItem(
//         value: i,
//         child: Text(
//           s,
//           style: TextStyle(color: Colors.white),
//         ),
//       ));
//     }
//     return l;
//   }
// }

import 'package:flutter/material.dart';
import 'package:AlphaReader/Helper/apiRequests.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'mangaView.dart';

class SearchView extends StatefulWidget {
  final maxPages, query;
  SearchView({this.maxPages, this.query});
  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  SearchData sd = SearchData();
  var data, w;
  String pageNo = '1', font = 'Montserrat';
  bool isLoading;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    await sd.getSearchData(widget.query, pageNo);
    data = sd.searchPageData;
    sd.searchPageData = [];
    setState(() {
      isLoading = false;
    });
  }

  getDataOnReload() async {
    await sd.getSearchData(widget.query, pageNo);
    data = sd.searchPageData;
    sd.searchPageData = [];
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    return isLoading
        ? Container(
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.purple[900],
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.black,
            body: sd.response == null
                ? SingleChildScrollView(
                    child: RefreshIndicator(
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
                        onRefresh: () async {
                          await getDataOnReload();
                          setState(() {});
                        }),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: GridView.builder(
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
                                  data[index].latestChapter);
                            },
                            itemCount: data.length,
                          ),
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
          );
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
}
