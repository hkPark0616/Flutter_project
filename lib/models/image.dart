class Images {
  late String? image; // image url
  late String? path;
  late String? postId;
  //late Uint8List? bytes;

  Images({
    required this.image, // image url
    required this.path,
    required this.postId,
    //required this.bytes,
  });

  Map<String, dynamic> toMap() {
    return {
      'image': image, // image url
      'path': path,
      'postId': postId,
      //'bytes': bytes,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image, // image url
      'path': path,
      'postId': postId,
    };
  }

  factory Images.fromFirestore(Map<String, dynamic> json) {
    return Images(
      image: json["image"], // image url
      path: json["path"],
      postId: json["postId"],
      //bytes: json["bytes"],
    );
  }

  // Images.fromSnapshot(DocumentSnapshot snapshot) {
  //   Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  //   // images = data['images'] != null
  //   //     ? List<String>.from(data['images'])
  //   //     : null; // 이미지 리스트 추가
  //   image = data['image']; // image url
  //   path = data['path'];
  //   postId = data['postId'];
  // }
}
