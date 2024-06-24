import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/models/board.dart';
import 'package:myapp/providers/board_provider.dart';
import 'package:myapp/providers/comment_provider.dart';
import 'package:myapp/providers/post_provider.dart';
import 'package:myapp/screens/detailScreen.dart';
import 'package:myapp/screens/tokenCheck.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

// 백그라운드 핸들러
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  // showFlutterNotification(
  //     message); // heads up nitification( show twice notification...)
}

// Foreground 알림 클릭
onSelectNotification(NotificationResponse details) async {
  // 해당 게시글로 이동
  if (details.payload != null) {
    // Map<String, dynamic> data = jsonDecode(details.payload ?? "");
    // Get.toNamed(data.keys.first, arguments: int.parse(data.values.first));
    dynamic data = jsonDecode(details.payload ?? "");
    Map<String, String> userData = {};

    Board board = Board(
      postId: data['postId'],
      title: data['title'],
      contents: data['contents'],
      date: data['date'],
      writer: data['writer'],
      writerId: data['writerId'],
      postLike: int.parse(data['postLike']),
      postComment: int.parse(data['postComment']),
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? getEmail = prefs.getString('userEmail');
    String? getDate = prefs.getString('createdDate');
    String? getUserId = prefs.getString('userId');

    if (getEmail == "null" && getDate == "null" && getUserId == "null") {
      userData = {
        "userEmail": getEmail!,
        "userCreatedDate": getDate!,
        "userId": getUserId!,
      };
      print(userData);
      Navigator.of(navState.currentContext!).push(
        MaterialPageRoute(
          builder: (context) => const TokenCheck(),
        ),
      );
    } else {
      Navigator.of(navState.currentContext!).push(
        MaterialPageRoute(
          builder: (context) => DetailScreen(
            content: board,
            userInfo: userData,
          ),
        ),
      );
    }
  }
}

final GlobalKey<NavigatorState> navState = GlobalKey<NavigatorState>();

bool isFlutterLocalNotificationsInitialized = false;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
late AndroidNotificationChannel channel;

/// 셋팅 메소드
Future<void> setupFlutterNotifications() async {
  // if (isFlutterLocalNotificationsInitialized) {
  //   return;
  // }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id는 AndroidManifest.xml 파일에서 설정한 default_notification_channel_id 값과 같아야한다
    // 'High Importance Notifications', // title
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIos = const DarwinInitializationSettings();

  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIos,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveBackgroundNotificationResponse: onSelectNotification,
    onDidReceiveNotificationResponse: onSelectNotification,
  );

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
    announcement: true,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: true,
    sound: true,
  );

  // 토큰 요청
  //getToken();
  // 셋팅flag 설정
  //isFlutterLocalNotificationsInitialized = true;
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
      payload: jsonEncode(message.data), //필수
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
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

  //print('FCM Token: $token');
}

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }

void main() async {
  // Firebase initialize
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //getToken();

  // 백그라운드 설정
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 앱일경우만 firebase setting 함수 실행
  if (!kIsWeb) {
    await setupFlutterNotifications();
  }

  //HttpOverrides.global = MyHttpOverrides();

  // run MyApp
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BoardProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Foreground 수신처리
    FirebaseMessaging.onMessage.listen(showFlutterNotification);

    // Background 수신처리
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Background, 앱 종료 시 알림 클릭
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      // 해당 게시글로 이동
      dynamic data = message.data;
      final Map<String, String> userData = {};
      //print("데이터 받음 $data");
      //Board test = message.data as Board;
      Board board = Board(
        postId: data['postId'],
        title: data['title'],
        contents: data['contents'],
        date: data['date'],
        writer: data['writer'],
        writerId: data['writerId'],
        postLike: int.parse(data['postLike']),
        postComment: int.parse(data['postComment']),
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? getEmail = prefs.getString('userEmail');
      String? getDate = prefs.getString('createdDate');
      String? getUserId = prefs.getString('userId');

      if (getEmail == "null" && getDate == "null" && getUserId == "null") {
        final Map<String, String> userData = {
          "userEmail": getEmail!,
          "userCreatedDate": getDate!,
          "userId": getUserId!,
        };

        Navigator.of(navState.currentContext!).push(
          MaterialPageRoute(
            builder: (context) => const TokenCheck(),
          ),
        );
      } else {
        Navigator.of(navState.currentContext!).push(
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              content: board,
              userInfo: userData,
            ),
          ),
        );
      }
    });

    //앱꺼진상태에서 알림 클릭
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) async {
      dynamic data = message?.data;
      Map<String, String> userData = {};
      Board board = Board(
        postId: data['postId'],
        title: data['title'],
        contents: data['contents'],
        date: data['date'],
        writer: data['writer'],
        writerId: data['writerId'],
        postLike: int.parse(data['postLike']),
        postComment: int.parse(data['postComment']),
      );
      // 해당 게시글로 이동
      if (message != null) {
        // Get.toNamed(message.data.keys.first,
        //     arguments: int.parse(message.data.values.first));
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? getEmail = prefs.getString('userEmail');
        String? getDate = prefs.getString('createdDate');
        String? getUserId = prefs.getString('userId');

        if (getEmail == "null" && getDate == "null" && getUserId == "null") {
          userData = {
            "userEmail": getEmail!,
            "userCreatedDate": getDate!,
            "userId": getUserId!,
          };

          Navigator.of(navState.currentContext!).push(
            MaterialPageRoute(
              builder: (context) => const TokenCheck(),
            ),
          );
        } else {
          Navigator.of(navState.currentContext!).push(
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                content: board,
                userInfo: userData,
              ),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navState,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Dongle',
      ),
      home: const TokenCheck(),
    );
  }
}
