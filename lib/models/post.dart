import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/image.dart';

class Post {
  late String? postId;
  late String? title;
  late String? contents;
  late String? date;
  late String? writer;
  late String? writerId;
  late int? postLike;
  late int? postComment;
  late List<Images>? images; // 이미지 리스트 추가

  Post({
    required this.postId,
    required this.title,
    required this.contents,
    required this.date,
    required this.writer,
    required this.writerId,
    required this.postLike,
    required this.postComment,
    this.images, // 이미지 리스트 추가
  });

  Post.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    postId = snapshot.id;
    title = data['title'];
    contents = data['contents'];
    date = data['date'];
    writer = data['writer'];
    writerId = data['writerId'];
    postLike = data['postLike'];
    postComment = data['postComment'];
    images = data['images'] != null
        ? List<Images>.from(data['images'])
        : null; // 이미지 리스트 추가
  }
}
