import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/image.dart';

class ImagesProvider extends ChangeNotifier {
  List<Images> items = [];

  Future<void> fetchItems(String postId) async {
    ListResult result =
        await FirebaseStorage.instance.ref("images/$postId").listAll();
    for (final item in result.items) {
      String imageUrl = await item.getDownloadURL();
      // items.add(Images(image: imageUrl, path: '', postId: '', bytes: null));
      items.add(Images(image: imageUrl, path: '', postId: ''));
    }
    notifyListeners();
  }

// }
}
