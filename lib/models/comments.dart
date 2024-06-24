import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  late String? postId;
  late String? commentId;
  late String? comment;
  late int? depth;
  late String? seq;
  late String? date;
  late String? commentWriter;
  late String? parent;

  Comment({
    required this.postId,
    required this.commentId,
    required this.comment,
    required this.depth,
    required this.seq,
    required this.date,
    required this.commentWriter,
    required this.parent,
  });

  get title => null;

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'commentId': commentId,
      'comment': comment,
      'depth': depth,
      'seq': seq,
      'date': date,
      'commentWriter': commentWriter,
      'parent': parent,
    };
  }

  Comment.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    postId = data['postId'];
    commentId = data['commentId'];
    comment = data['comment'];
    depth = data['depth'];
    seq = data['seq'];
    date = data['date'];
    commentWriter = data['commentWriter'];
    parent = data['parent'];
    // images = data['images'] != null
    //     ? List<String>.from(data['images'])
    //     : null; // 이미지 리스트 추가
  }
}
