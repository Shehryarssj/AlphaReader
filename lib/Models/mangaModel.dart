class MangaModel {
  String title,
      latestChapter,
      latestChapterLink,
      image,
      mangaUrl,
      status,
      description,
      lastUpdated;
  List authors, chapters, genres;
  MangaModel({
    this.latestChapter,
    this.latestChapterLink,
    this.image,
    this.title,
    this.mangaUrl,
    this.chapters,
    this.authors,
    this.status,
    this.genres,
    this.description,
    this.lastUpdated,
  });
}
