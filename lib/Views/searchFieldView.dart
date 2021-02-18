import 'package:flutter/material.dart';
import 'package:AlphaReader/Helper/apiRequests.dart';
import 'searchView.dart';

class SearchFieldView extends StatefulWidget {
  @override
  _SearchFieldViewState createState() => _SearchFieldViewState();
}

class _SearchFieldViewState extends State<SearchFieldView> {
  String font = 'Montserrat';
  final _formKey = GlobalKey<FormState>();
  String query = '';
  var w;
  MaxPages mp = MaxPages();

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Form(
            key: _formKey,
            child: Container(
              margin: EdgeInsets.only(top: 15),
              height: 40,
              width: w - 100,
              child: getTextFormField(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget getTextFormField(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.search,
      cursorColor: Colors.grey,
      decoration: InputDecoration(
        hintText: 'Enter Manga Name',
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.purple[900])),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.purple[900]),
        ),
        hintStyle: TextStyle(
            color: Colors.grey,
            fontFamily: font,
            fontSize: 14,
            fontWeight: FontWeight.bold),
      ),
      style: TextStyle(
        color: Colors.white,
        fontFamily: font,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      onChanged: (value) {
        query = value;
      },
      validator: (value) {
        return value.length > 2 ? null : "Enter Three Characters Or More";
      },
      onFieldSubmitted: (value) async {
        if (_formKey.currentState.validate()) {
          alertDialog(context, '');
          await mp.getMaxPagesSearch(value);
          Navigator.pop(context);
          if (mp.response != null) {
            if (mp.maxPages != '0') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchView(
                    maxPages: mp.maxPages,
                    query: query,
                  ),
                ),
              );
            } else {
              alertDialog(context, 'No Results');
            }
          } else {
            alertDialog(context, 'Network Error');
          }
        }
      },
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
}
// Widget mangaCard(
//     String imageUrl, String title, String mangaUrl, String latestChapter) {
//   var w = MediaQuery.of(context).size.width;
//   return GestureDetector(
//     onTap: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => MangaView(
//             mangaUrl: mangaUrl,
//             imageUrl: imageUrl,
//           ),
//         ),
//       );
//     },
//     child: Container(
//       alignment: Alignment.center,
//       margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//       child: Stack(
//         children: <Widget>[
//           //Image with the shadermask
//           Container(
//             width: w / 2.1,
//             height: w / 1.4,
//             child: ShaderMask(
//               shaderCallback: (rect) {
//                 return LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.transparent,
//                     Colors.transparent,
//                     Colors.black
//                   ],
//                 ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
//               },
//               blendMode: BlendMode.dstOut,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.all(Radius.circular(10)),
//                 child: CachedNetworkImage(
//                   width: w / 2.3,
//                   height: w / 1.6,
//                   imageUrl: imageUrl,
//                   fadeInCurve: Curves.easeIn,
//                   fadeInDuration: Duration(milliseconds: 500),
//                   fit: BoxFit.fill,
//                   errorWidget: (context, url, error) => Container(
//                     height: 100,
//                     decoration: BoxDecoration(
//                         border: Border.all(color: Colors.white)),
//                     child: Center(
//                       child: Text(
//                         'Network Error',
//                         style:
//                             TextStyle(fontFamily: font, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           //Text on the image
//           Container(
//               padding: EdgeInsets.only(left: 5),
//               alignment: Alignment.bottomLeft,
//               width: w / 2.3,
//               height: w / 1.6,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: <Widget>[
//                   Text(
//                     title,
//                     maxLines: 4,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontFamily: 'Montserrat',
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     "Chapter " + latestChapter,
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: 11,
//                       fontFamily: 'Montserrat',
//                       fontWeight: FontWeight.bold,
//                     ),
//                   )
//                 ],
//               ))
//         ],
//       ),
//     ),
//   );
// }
