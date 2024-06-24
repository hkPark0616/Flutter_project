import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/board.dart';
import 'package:myapp/models/image.dart';
import 'package:myapp/service/image_service.dart';

class BoardProvider extends ChangeNotifier {
  late CollectionReference boardsReference;
  List<Board> items = [];

  BoardProvider({reference}) {
    boardsReference =
        reference ?? FirebaseFirestore.instance.collection('posts');
  }

  // Future<void> fetchItems() async {
  //   items = await boardsReference
  //       .orderBy('date', descending: true)
  //       .get()
  //       .then((QuerySnapshot results) {
  //     return results.docs.map((DocumentSnapshot document) {
  //       return Board.fromSnapshot(document);
  //     }).toList();
  //   });
  //   notifyListeners();
  // }
  Future<void> fetchItems() async {
    items = await boardsReference
        .orderBy('date', descending: true)
        .get()
        .then((QuerySnapshot results) async {
      List<Board> boards = [];
      for (DocumentSnapshot document in results.docs) {
        Board board = Board.fromSnapshot(document);
        // 해당 게시글의 이미지 리스트를 가져옴
        List<Images> images = await ImageService.getImage(board.postId!);
        board.images = images;
        boards.add(board);
      }
      return boards;
    });
    notifyListeners();
  }

  // delete post with all comments
  Future<void> deletePost(String postId) async {
    // post
    await boardsReference.doc(postId).delete();
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
  }
}
