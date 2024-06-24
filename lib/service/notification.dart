import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/models/board.dart';

Future<void> sendNotificationToDevice(
    String userToken, String title, String content, Board data) async {
  String serverKey =
      "AAAATL6lskg:APA91bFTwOcRepADvzTKTaaN9xGuqhezobNUPNEp4_Ayj-M_hObzyo_WYuxLDoOnSvL2kUhn4lGJsYdaKVdxft_HubaMWaf1lOFdo2yKqhHtZ7e_d_H7DsTMFLy-J9zUdaGMfgGdxFyd";
  // final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

  http.Response response;

  // Board post = data;

  // Map<String, dynamic> datas = {
  //   'postId': data.postId,
  //   'title': data.title,
  //   'contents': data.contents,
  //   'date': data.date,
  //   'writer': data.writer,
  //   'writerId': data.writerId,
  //   'postLike': data.postLike,
  //   'postComment': data.postComment,
  //   'images': data['images'] != null ? List<Images>.from(data['images']) : null,
  // };

  //print(post.title);

  // final headers = {
  //   'Content-Type': 'application/json',
  //   'Authorization': 'key=$serverKey',
  // };

  // final body = {
  //   'notification': {'title': title, 'body': content, 'data': data.toMap()},
  //   'to': userToken,
  // };

  try {
    //response = await http.post(url, headers: headers, body: json.encode(body));
    response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey'
      },
      body: jsonEncode(
        {
          'notification': {
            'title': title,
            'body': content,
            "priority": "high",
          },
          'to': userToken,
          // 'data': <String, dynamic>{
          //   'title': post.title,
          // },
          // 'data': <String, dynamic>{
          //   'title': post.title,
          // },

          'data': data.toJson(),
          // 'data': Board(
          //   postId: data.postId,
          //   title: data.title,
          //   contents: data.contents,
          //   date: data.date,
          //   writer: data.writer,
          //   writerId: data.writerId,
          //   postLike: data.postLike,
          //   postComment: data.postComment,
          // ),
          // 'registration_ids': tokenList
        },
      ),
    );

    if (response.statusCode == 200) {
      // Notification sent successfully

      print("성공적으로 전송되었습니다.");

      // print("${data.title}");
    } else {
      // Failed to send notification

      print("전송에 실패하였습니다." + response.statusCode.toString());
    }
  } catch (e) {
    print("푸시 에러: " + e.toString());
  }
}
