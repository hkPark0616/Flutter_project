import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/comments.dart';

class CommentProvider extends ChangeNotifier {
  late CollectionReference commentsReference;
  List<Comment> items = [];

  CommentProvider({reference}) {
    commentsReference =
        reference ?? FirebaseFirestore.instance.collection('comments');
  }

  Future<void> fetchItems(String postId) async {
    items = await commentsReference
        .where('postId', isEqualTo: postId)
        .orderBy('parent', descending: false)
        .orderBy('seq', descending: false)
        .get()
        .then((QuerySnapshot results) {
      return results.docs.map((DocumentSnapshot document) {
        return Comment.fromSnapshot(document);
      }).toList();
    });
    notifyListeners();
  }

  // delete comments with all recomments
  Future<void> deleteComment(String parent, String postId) async {
    var deleteComment = commentsReference.where('parent', isEqualTo: parent);
    deleteComment.get().then((querySnapshot) async {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        "postComment": FieldValue.increment(-querySnapshot.docs.length),
      });
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });
    notifyListeners();
  }

  // delete recomments
  Future<void> deleteReComment(String commentId, String postId) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      "postComment": FieldValue.increment(-1),
    });
    await commentsReference.doc(commentId).delete();
    notifyListeners();
  }
}
