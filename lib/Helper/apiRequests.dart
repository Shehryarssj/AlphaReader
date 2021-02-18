import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/mangaModel.dart';

class MainPageData {
  List<MangaModel> updatesData = List<MangaModel>();
  List<MangaModel> topWeeklyData = List<MangaModel>();
  var response;

  getMainPageData() async {
    try {
      var url = 'https://manganelo-api.herokuapp.com/';
      response = await http.get(Uri.encodeFull(url), headers: {
        "Accept": "application/json"
      }).timeout(Duration(seconds: 20));
    } catch (e) {
      response = null;
      print(e.message);
    }
    if (response != null) {
      try {
        var responseBody = json.decode(response.body);
        var updates = responseBody['result']['updates'];
        var top = responseBody['result']['top_weekly'];
        for (var item in updates) {
          String chapter = item['latest_chapter'];
          String chapterLink = item['latest_chapter_link'];
          String title = item['title'];
          String image = item['image'];
          String mangaUrl = item['manga_url'];
          MangaModel manga = MangaModel(
              latestChapter: chapter,
              latestChapterLink: chapterLink,
              image: image,
              title: title,
              mangaUrl: mangaUrl);
          updatesData.add(manga);
        }
        for (var item in top) {
          String chapter = item['latest_chapter'];
          String chapterLink = item['latest_chapter_link'];
          String title = item['title'];
          String image = item['image'];
          String mangaUrl = item['manga_url'];
          MangaModel manga = MangaModel(
              latestChapter: chapter,
              latestChapterLink: chapterLink,
              image: image,
              title: title,
              mangaUrl: mangaUrl);
          topWeeklyData.add(manga);
        }
      } catch (e) {
        print(e);
      }
    }
    return 'done';
  }
}

class MangaData {
  MangaModel mangaData = MangaModel();
  var response;
  int i = 1;

  getMangaData(String u) async {
    try {
      var url = 'https://manganelo-api.herokuapp.com/get_manga_info?url=$u';

      response = await http.get(Uri.encodeFull(url), headers: {
        "Accept": "application/json"
      }).timeout(Duration(seconds: 20));
    } catch (e) {
      print(e.message);
      response = null;
    }
    if (response != null) {
      i += 1;
      var responseBody;
      try {
        responseBody = json.decode(response.body);
        var data = responseBody;

        String mangaName = data['manga_name'];
        String mangaImage = data['manga_image'];
        List authors = data['authors'];
        List chapters = data['chapters'];
        List genres = data['genres'];
        String status = data['status'];
        String description = data['description'];
        String lastUpdated = data['last_updated'];

        MangaModel manga = MangaModel(
          image: mangaImage,
          title: mangaName,
          mangaUrl: u,
          authors: authors,
          chapters: chapters,
          genres: genres,
          status: status,
          description: description,
          lastUpdated: lastUpdated,
        );
        mangaData = manga;
      } catch (e) {
        response = null;
        print(e.message);
      }
    }
    return 'done';
  }
}

class ChapterData {
  List imageLinks;
  var response;

  getChapterData(String u) async {
    try {
      var url =
          'https://manganelo-api.herokuapp.com/chapter_image_links?url=$u';
      response = await http.get(Uri.encodeFull(url), headers: {
        "Accept": "application/json"
      }).timeout(Duration(seconds: 20));
    } catch (e) {
      response = null;
      print(e.message);
    }
    if (response != null) {
      try {
        var responseBody = json.decode(response.body);
        var data = responseBody['image_links'];
        imageLinks = data;
      } catch (e) {
        print(e.message);
        response = null;
      }
    }
    return 'done';
  }
}

class SearchData {
  List<MangaModel> searchPageData = List<MangaModel>();
  var response;

  getSearchData(String query, String page) async {
    try {
      var url =
          'https://manganelo-api.herokuapp.com/get_search_results_for_page?arg=' +
              query +
              ',' +
              page;
      response = await http.get(Uri.encodeFull(url), headers: {
        "Accept": "application/json"
      }).timeout(Duration(seconds: 20));
    } catch (e) {
      response = null;
      print(e.message);
    }
    if (response != null) {
      try {
        var responseBody = json.decode(response.body);
        var data = responseBody['result'];

        for (var item in data) {
          String chapter = item['latest_chapter'];
          String chapterLink = item['latest_chapter_link'];
          String title = item['manga_title'];
          String image = item['manga_img'];
          String mangaUrl = item['manga_url'];

          MangaModel manga = MangaModel(
              latestChapter: chapter,
              latestChapterLink: chapterLink,
              image: image,
              title: title,
              mangaUrl: mangaUrl);
          searchPageData.add(manga);
        }
      } catch (e) {
        print(e.message);
        response = null;
      }
    }

    return 'done';
  }
}

class MaxPages {
  String maxPages;
  var response;

  getMaxPagesSearch(String query) async {
    try {
      var url =
          'https://manganelo-api.herokuapp.com/get_total_search_result_pages?query=$query';

      response = await http.get(Uri.encodeFull(url), headers: {
        "Accept": "application/json"
      }).timeout(Duration(seconds: 20));
    } catch (e) {
      print(e.message);
      response = null;
    }
    if (response != null) {
      try {
        var resposeBody = json.decode(response.body);
        maxPages = resposeBody['maxpages'];
      } catch (e) {
        print(e.message);
        response = null;
      }
    }

    return 'done';
  }

  getMaxPagesGenreSearch(Map<String, String> genres) async {
    Map<String, String> genreNumbers = {
      'Action': '2',
      'Adult': '3',
      'Adventure': '4',
      'Comedy': '6',
      'Cooking': '7',
      'Doujinshi': '9',
      'Drama': '10',
      'Ecchi': '11',
      'Fantasy': '12',
      'Gender Bender': '13',
      'Harem': '14',
      'Historical': '15',
      'Horror': '16',
      'Isekai': '45',
      'Josei': '17',
      'Manhua': '44',
      'Manhwa': '43',
      'Martial Arts': '19',
      'Mature': '20',
      'Mecha': '21',
      'Medical': '22',
      'Mystery': '24',
      'One Shot': '25',
      'Psychological': '26',
      'Romance': '27',
      'School Life': '28',
      'Sci Fi': '29',
      'Seinin': '30',
      'Shoujo': '31',
      'Shoujo Ai': '32',
      'Shounen': '33',
      'Shounen Ai': '34',
      'Slice Of Life': '35',
      'Smut': '36',
      'Sports': '37',
      'Supernatural': '38',
      'Tragedy': '39',
      'Webtoons': '40',
      'Yaoi': '41',
      'Yuri': '42'
    };
    try {
      List selected = [];
      List excluded = [];
      String selectedGenres;
      String excludedGenres;
      for (String genre in genres.keys) {
        if (genres[genre] == 'selected') {
          selected.add(genreNumbers[genre]);
        } else if (genres[genre] == 'excluded') {
          excluded.add(genreNumbers[genre]);
        }
      }
      if (selected.length != 0) {
        selectedGenres = '_' + selected.join('_') + '_';
      } else {
        selectedGenres = '';
      }
      if (excluded.length != 0) {
        excludedGenres = '_' + excluded.join('_') + '_';
      } else {
        excludedGenres = '';
      }
      var url =
          'https://manganelo-api.herokuapp.com/get_total_genre_search_result_pages?arg=' +
              selectedGenres +
              ',' +
              excludedGenres;

      response = await http.get(Uri.encodeFull(url), headers: {
        "Accept": "application/json"
      }).timeout(Duration(seconds: 20));
    } catch (e) {
      print(e.message);
      response = null;
    }
    if (response != null) {
      try {
        var resposeBody = json.decode(response.body);
        maxPages = resposeBody['max_pages'];
      } catch (e) {
        print(e.message);
        response = null;
      }
    }

    return 'done';
  }
}

class GenreSearchData {
  List<MangaModel> searchPageData = List<MangaModel>();

  var response;
  getGenreSearchData(Map<String, String> genres, String page) async {
    //Numbers associated with each genre
    Map<String, String> genreNumbers = {
      'Action': '2',
      'Adult': '3',
      'Adventure': '4',
      'Comedy': '6',
      'Cooking': '7',
      'Doujinshi': '9',
      'Drama': '10',
      'Ecchi': '11',
      'Fantasy': '12',
      'Gender Bender': '13',
      'Harem': '14',
      'Historical': '15',
      'Horror': '16',
      'Isekai': '45',
      'Josei': '17',
      'Manhua': '44',
      'Manhwa': '43',
      'Martial Arts': '19',
      'Mature': '20',
      'Mecha': '21',
      'Medical': '22',
      'Mystery': '24',
      'One Shot': '25',
      'Psychological': '26',
      'Romance': '27',
      'School Life': '28',
      'Sci Fi': '29',
      'Seinin': '30',
      'Shoujo': '31',
      'Shoujo Ai': '32',
      'Shounen': '33',
      'Shounen Ai': '34',
      'Slice Of Life': '35',
      'Smut': '36',
      'Sports': '37',
      'Supernatural': '38',
      'Tragedy': '39',
      'Webtoons': '40',
      'Yaoi': '41',
      'Yuri': '42'
    };
    try {
      List selected = [];
      List excluded = [];
      String selectedGenres;
      String excludedGenres;
      for (String genre in genres.keys) {
        if (genres[genre] == 'selected') {
          selected.add(genreNumbers[genre]);
        } else if (genres[genre] == 'excluded') {
          excluded.add(genreNumbers[genre]);
        }
      }
      if (selected.length != 0) {
        selectedGenres = '_' + selected.join('_') + '_';
      } else {
        selectedGenres = '';
      }
      if (excluded.length != 0) {
        excludedGenres = '_' + excluded.join('_') + '_';
      } else {
        excludedGenres = '';
      }

      var url =
          'https://manganelo-api.herokuapp.com/get_genre_search_results?arg=' +
              selectedGenres +
              ',' +
              excludedGenres +
              ',' +
              page;
      response = await http.get(Uri.encodeFull(url), headers: {
        "Accept": "application/json"
      }).timeout(Duration(seconds: 20));
    } catch (e) {
      response = null;
      print(e.message);
    }
    if (response != null) {
      try {
        var responseBody = json.decode(response.body);
        var data = responseBody['mangas'];

        for (var item in data) {
          String chapter = item['latest_chapter'];
          String chapterLink = item['latest_chapter_link'];
          String title = item['title'];
          String image = item['image'];
          String mangaUrl = item['manga_url'];

          MangaModel manga = MangaModel(
            latestChapter: chapter,
            latestChapterLink: chapterLink,
            image: image,
            title: title,
            mangaUrl: mangaUrl,
          );
          searchPageData.add(manga);
        }
      } catch (e) {
        print(e.message);
        response = null;
      }
    }
    return 'done';
  }
}
