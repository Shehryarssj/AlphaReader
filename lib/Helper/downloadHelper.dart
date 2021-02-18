import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';

findPath(String imageUrl, String i, String title, String chapter) async {
  chapter = 'Chapter_' + chapter;
  var file;
  file = await DefaultCacheManager().getSingleFile(imageUrl);

  String path = '/storage/emulated/0';
  await Directory('$path/AlphaReader').create();
  path = path + '/AlphaReader';
  await Directory('$path/$title').create();
  path = path + '/$title';
  await Directory('$path/$chapter').create();
  path = path + '/$chapter/';

  await copyFile(file, path + i + '.jpg');
}

copyFile(File sourceFile, String newPath) async {
  try {
    final newFile = await sourceFile.copy(newPath);
    return newFile;
  } on FileSystemException catch (e) {
    print(e);
  }
}
