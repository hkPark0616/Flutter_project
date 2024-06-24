import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/image.dart';

class ImageService {
  static Future<List<String>> getPostImage(String postId) async {
    List<String> images = [];
    ListResult result =
        await FirebaseStorage.instance.ref("images/$postId").listAll();
    for (final item in result.items) {
      String imageUrl = await item.getDownloadURL();
      images.add(imageUrl);
    }

    return images;
  }

  static Future<List<Images>> getImage(String postId) async {
    List<Images> images = [];
    QuerySnapshot<Map<String, dynamic>> result = await FirebaseFirestore
        .instance
        .collection('posts')
        .doc(postId)
        .collection('images')
        .where('postId', isEqualTo: postId)
        .get();

    images = result.docs.map((e) => Images.fromFirestore(e.data())).toList();

    return images;
  }
}
