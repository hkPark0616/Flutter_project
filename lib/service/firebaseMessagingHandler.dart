import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
/*
 이 함수가 라이브러리 외부에서 호출될 가능성이 없는 경우, 
 @pragma('vm:entry-point')로 지정하여 AOT 컴파일러가 해당 함수를 컴파일하지 않도록 하여
 컴파일 시간과 크기를 줄일 수 있습니다.
*/
bool isFlutterLocalNotificationsInitialized = false;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
late AndroidNotificationChannel channel;

/// 셋팅 메소드
Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id는 AndroidManifest.xml 파일에서 설정한 default_notification_channel_id 값과 같아야한다
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  // iOS foreground notification 권한
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  // IOS background 권한 체킹 , 요청
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  // 토큰 요청
  //getToken();
  // 셋팅flag 설정
  isFlutterLocalNotificationsInitialized = true;
}

// forground에서 알림 표시하기
void showFlutterNotification(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}

Future<void> getToken() async {
  String? token;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // 플랫폼 별 토큰 가져오기
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    token = await messaging.getAPNSToken();
  } else {
    token = await messaging.getToken();
  }

  print('FCM Token: $token');
}
