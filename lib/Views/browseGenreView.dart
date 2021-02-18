import 'package:AlphaReader/Views/genreSearchView.dart';
import 'package:flutter/material.dart';
import 'package:AlphaReader/Helper/apiRequests.dart';

class BrowseGenre extends StatefulWidget {
  @override
  _BrowseGenreState createState() => _BrowseGenreState();
}

class _BrowseGenreState extends State<BrowseGenre> {
  String font = 'Montserrat';
  String maxPages;
  Map<String, String> genres = Map();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Pick Your Poison',
              style: TextStyle(
                  color: Colors.white, fontFamily: font, fontSize: 22),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '(Tap To Add Or Exclude. Long Press To Reset)',
              style: TextStyle(
                  color: Colors.white, fontFamily: font, fontSize: 10),
            ),
            SizedBox(
              height: 10,
            ),
            getRow('Action', 'Adult', 'Adventure', 'Comedy'),
            getRow('Cooking', 'Doujinshi', 'Drama', 'Ecchi'),
            getRow('Fantasy', 'Gender Bender', 'Harem', 'Historical'),
            getRow('Horror', 'Isekai', 'Josei', 'Manhua'),
            getRow('Manhwa', 'Martial Arts', 'Mature', 'Mecha'),
            getRow('Medical', 'Mystery', 'One Shot', 'Psychological'),
            getRow('Romance', 'School Life', 'Sci Fi', 'Seinin'),
            getRow('Shoujo', 'Shoujo Ai', 'Shounen', 'Shounen Ai'),
            getRow('Slice Of Life', 'Smut', 'Sports', 'Supernatural'),
            getRow('Tragedy', 'Webtoons', 'Yaoi', 'Yuri'),
            Container(
              width: (MediaQuery.of(context).size.width) / 4,
              child: ButtonTheme(
                minWidth: 20,
                child: RaisedButton(
                  color: Colors.white,
                  onPressed: () async {
                    if (genres.length != 0) {
                      MaxPages mp = MaxPages();
                      alertDialog(context, '');
                      await mp.getMaxPagesGenreSearch(genres);
                      Navigator.pop(context);
                      if (mp.response != null) {
                        if (mp.maxPages != '0') {
                          maxPages = mp.maxPages;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GenreSearch(
                                maxPages: maxPages,
                                genres: genres,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        'Go',
                        style: TextStyle(
                            color: Colors.purple[900],
                            fontFamily: font,
                            fontSize: 16),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.purple[900],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getRow(String genre1, String genre2, String genre3, String genre4) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InkWell(
          child: buttonContainer(genre1),
          onTap: () {
            setState(() {
              if (genres[genre1] == null || genres[genre1] == 'excluded') {
                genres[genre1] = 'selected';
              } else {
                genres[genre1] = 'excluded';
              }
            });
          },
          onLongPress: () {
            setState(() {
              genres[genre1] = null;
            });
          },
        ),
        InkWell(
          onTap: () {
            setState(() {
              if (genres[genre2] == null || genres[genre2] == 'excluded') {
                genres[genre2] = 'selected';
              } else {
                genres[genre2] = 'excluded';
              }
            });
          },
          onLongPress: () {
            setState(() {
              genres[genre2] = null;
            });
          },
          child: buttonContainer(genre2),
        ),
        InkWell(
          onTap: () {
            setState(() {
              if (genres[genre3] == null || genres[genre3] == 'excluded') {
                genres[genre3] = 'selected';
              } else {
                genres[genre3] = 'excluded';
              }
            });
          },
          onLongPress: () {
            setState(() {
              genres[genre3] = null;
            });
          },
          child: buttonContainer(genre3),
        ),
        InkWell(
          onTap: () {
            setState(() {
              if (genres[genre4] == null || genres[genre4] == 'excluded') {
                genres[genre4] = 'selected';
              } else {
                genres[genre4] = 'excluded';
              }
            });
          },
          onLongPress: () {
            setState(() {
              genres[genre4] = null;
            });
          },
          child: buttonContainer(genre4),
        )
      ],
    );
  }

  Container buttonContainer(String t) {
    var color;

    var value = genres[t];

    if (value == 'selected') {
      color = Colors.green;
    } else if (value == 'excluded') {
      color = Colors.red;
    } else {
      color = Colors.purple[900];
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          color: color,
          borderRadius: BorderRadius.circular(15)),
      child: Text(
        t,
        style: TextStyle(color: Colors.white, fontFamily: font, fontSize: 12),
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
}
