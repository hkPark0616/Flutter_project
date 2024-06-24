import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/image.dart';
import 'package:myapp/models/post.dart';
import 'package:myapp/service/image_service.dart';

class PostProvider extends ChangeNotifier {
  late CollectionReference postsReference;
  List<Post> items = [];

  PostProvider({reference}) {
    postsReference =
        reference ?? FirebaseFirestore.instance.collection('posts');
  }

  // Future<void> fetchItems(String postId) async {
  //   // .where('postId', isEqualTo: postId)
  //   items = await postsReference
  //       .where('postId', isEqualTo: postId)
  //       .get()
  //       .then((QuerySnapshot results) {
  //     return results.docs.map((DocumentSnapshot document) {
  //       return Post.fromSnapshot(document);
  //     }).toList();
  //   });
  //   notifyListeners();
  // }

  Future<void> fetchItems(String postId) async {
    items = await postsReference
        .where('postId', isEqualTo: postId)
        .get()
        .then((QuerySnapshot results) async {
      List<Post> posts = [];
      for (DocumentSnapshot document in results.docs) {
        Post post = Post.fromSnapshot(document);
        // 해당 게시글의 이미지 리스트를 가져옴
        List<Images> images = await ImageService.getImage(post.postId!);
        post.images = images;
        posts.add(post);
      }
      return posts;
    });
    notifyListeners();
  }

  Future<void> deletePost(String postId, List<Images> list) async {
    try {
      // firebase firestore post & image data
      await postsReference.doc(postId).delete();

      await postsReference
          .doc(postId)
          .collection('images')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      // firebase storage images
      if (list.isNotEmpty) {
        //FirebaseStorage.instance.ref("images/$postId/").delete();
        await FirebaseStorage.instance
            .ref("images/$postId")
            .listAll()
            .then((value) {
          value.items.forEach((element) {
            FirebaseStorage.instance.ref(element.fullPath).delete();
          });
        });
      }

      // comments
      var deleteComments = FirebaseFirestore.instance
          .collection('comments')
          .where('postId', isEqualTo: postId);
      deleteComments.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updatePost(
      String postId, String title, String contents, imageList) async {
    try {
      // 기존 게시글의 제목과 내용 Update
      FirebaseFirestore.instance.collection('posts').doc(postId).update({
        "title": title,
        "contents": contents,
      });

      //await postsReference.doc(postId).delete();
      // 기존 이미지 데이터 제거 후
      await postsReference
          .doc(postId)
          .collection('images')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      // 기존 이미지 제거 후
      if (imageList.isNotEmpty) {
        //FirebaseStorage.instance.ref("images/$postId/").delete();
        await FirebaseStorage.instance
            .ref("images/$postId")
            .listAll()
            .then((value) {
          value.items.forEach((element) {
            FirebaseStorage.instance.ref(element.fullPath).delete();
          });
        });
      }

      // 업데이트된 이미지 저장
      for (int i = 0; i < imageList.length; i++) {
        Uint8List bytes = await imageList[i]!.readAsBytes();
        // storage
        String storagePath = 'images/$postId/image_$i';

        // FirebaseStorage에 이미지 저장
        await FirebaseStorage.instance.ref(storagePath).putData(
              bytes,
              SettableMetadata(
                contentType: "image/png",
              ),
            );
        // FirebaseStorage에 저장된 이미지 url 얻기
        final String _urlString =
            await FirebaseStorage.instance.ref(storagePath).getDownloadURL();
        // Firestore에 이미지 데이터 저장
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('images')
            .add(
              Images(
                image: _urlString,
                path: storagePath,
                postId: postId,
                //bytes: bytes,
              ).toMap(),
            );
      }
    } catch (e) {
      print(e);
    }
  }

  // post like( + 1 like )
  Future<void> postLike(String userId, String postId, likes) async {
    await FirebaseFirestore.instance
        .collection('likes')
        .doc(userId)
        .set(likes.toMap());
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      "postLike": FieldValue.increment(1),
    });
  }

  // cancle post like ( - 1 like )
  Future<void> postDislike(String postId, String userId) async {
    await FirebaseFirestore.instance
        .collection('likes')
        .where('postId', isEqualTo: postId)
        .where('userId', isEqualTo: userId)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      "postLike": FieldValue.increment(-1),
    });
  }
}
