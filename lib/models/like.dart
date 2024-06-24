class Likes {
  late String? postId; // image url
  late String? userEmail;
  late String? userId;

  Likes({
    required this.postId, // image url
    required this.userId,
    required this.userEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId, // image url
      'userId': userId,
      'userEmail': userEmail,
    };
  }
}
