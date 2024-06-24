import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/board_provider.dart';
import 'package:myapp/screens/detailScreen.dart';
import 'package:myapp/screens/writeScreen.dart';
import 'package:myapp/service/popScope.dart';
import 'package:myapp/widget/drawer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardScreen extends StatefulWidget {
  final String? userEmail;
  final String? createdDate;
  final String? userId;

  const BoardScreen({
    super.key,
    required this.userEmail,
    required this.createdDate,
    required this.userId,
  });

  @override
  State<BoardScreen> createState() => BoardState();
}

class BoardState extends State<BoardScreen> {
  @override
  void initState() {
    super.initState();
    getPermissions();
    _loadUserInfo();
    fcmTokenCheck();
    //loadPost();
  }

  // user info data
  late Map<String, String> userData;
  String currentUserEmail = '';
  String currentCreatedDate = '';
  String currentUserId = '';

  bool isLoading = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  Future<void> getPermissions() async {
    // 카메라 권한 요청
    final cameraPermissionStatus = await Permission.camera.request();

    // 저장소 권한 요청
    final storagePermissionStatus = await Permission.storage.request();

    // 알림 권한 요청
    final notificationPermissionStatus =
        await Permission.notification.request();
  }

  // 사용자 fcm 토큰 확인 및 갱신
  Future<void> fcmTokenCheck() async {
    String? oldToken = '';
    String? newToken = '';
    String userId = currentUserId.isEmpty ? widget.userId! : currentUserId;
    String userEmail =
        currentUserEmail.isEmpty ? widget.userEmail! : currentUserEmail;
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 사용자 토큰 가져오기
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: userId)
        .get();
    oldToken = querySnapshot.docs[0]['token'];

    // 플랫폼 별 토큰 가져오기
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      newToken = (await messaging.getAPNSToken())!;
    } else {
      newToken = (await messaging.getToken())!;
    }

    if (oldToken != newToken) {
      FirebaseFirestore.instance.collection('users').doc(userEmail).update({
        "token": newToken,
      });
    }
  }

  // get user data to sharedpreferences
  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? getEmail = prefs.getString('userEmail');
    String? getDate = prefs.getString('createdDate');
    String? getUserId = prefs.getString('userId');

    setState(() {
      // auto login(exist SharedPreferences date)
      if (getEmail == "null" && getDate == "null" && getUserId == "null") {
        currentUserEmail = prefs.getString('userEmail')!;
        currentCreatedDate = prefs.getString('createdDate')!;
        currentUserId = prefs.getString('userId')!;
      }
      // not auto login(not exist SharedPreferences date)
      else {
        currentUserEmail = widget.userEmail!;
        currentCreatedDate = widget.createdDate!;
        currentUserId = widget.userId!;
      }
    });

    // userData = User(
    //   userEmail: currentUserEmail,
    //   userCreatedDate: currentCreatedDate,
    //   userId: currentUserId,
    // );
    userData = {
      "userEmail": currentUserEmail,
      "userCreatedDate": currentCreatedDate,
      "userId": currentUserId,
    };
  }

  Future<void> _refreshPosts(BuildContext context) async {
    await Provider.of<BoardProvider>(context, listen: false).fetchItems();
  }

  // Future<dynamic> getPostImage(String postId) async {
  //   List images = [];
  //   Map<String, dynamic> list;
  //   ListResult result =
  //       await FirebaseStorage.instance.ref("images/$postId").listAll();
  //   for (final e in result.items) {
  //     list = {
  //       'image': await e.getDownloadURL(),
  //     };
  //     images.add(list);
  //   }
  //   return images;
  // }

  @override
  Widget build(BuildContext context) {
    var boardProvider = Provider.of<BoardProvider>(context);
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          goBack();
        },
        child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white, size: 26.0),
            centerTitle: true,
            backgroundColor: const Color(0xFF9F7BFF),
            title: const Text(
              '자유게시판',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                fontFamily: 'Dongle',
                color: Colors.white,
              ),
            ),
          ),
          drawer: CustomDrawer(
              userEmail: currentUserEmail,
              createdDate: currentCreatedDate,
              userId: currentUserId),
          body: RefreshIndicator(
            onRefresh: () => _refreshPosts(context),
            child: FutureBuilder(
              //future: loadPost(),
              future: boardProvider.fetchItems(),
              builder: (context, snapshot) {
                //_posts = context.watch<BoardProvider>().boardList;
                //boardProvider = Provider.of<BoardProvider>(context);

                if (boardProvider.items.length == 0) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/emptyicon.png'),
                              fit: BoxFit.cover,
                            ),
                          ),

                          //image: AssetImage('assets/images/emplyicon.png'),
                        ),
                        const Text(
                          "게시글이 없습니다.",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Dongle'),
                        )
                      ],
                    ),
                  );
                } else {
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return const Center(
                  //     child: CircularProgressIndicator(
                  //       valueColor:
                  //           AlwaysStoppedAnimation<Color>(Color(0xFF9F7BFF)),
                  //     ),
                  //   );
                  // } else {
                  return ListView.builder(
                    controller: _scrollController,
                    //padding: const EdgeInsets.only(top: 15),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: boardProvider.items.length,
                    itemBuilder: (BuildContext context, int index) {
                      double width = MediaQuery.of(context).size.width;
                      DateTime date =
                          DateTime.parse(boardProvider.items[index].date!);

                      return InkWell(
                        //onTap: () => postClickEvent(context, index),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // 정의한 ContentPage의 폼 호출
                              builder: (context) => DetailScreen(
                                  content: boardProvider.items[index],
                                  userInfo: userData),
                            ),
                          );

                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     // 정의한 ContentPage의 폼 호출
                          //     builder: (context) => DetailScreen(
                          //         postId: boardProvider.items[index].postId!),
                          //   ),
                          // );
                        },
                        highlightColor: Colors.purple[50],
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.only(bottom: 5, top: 15),
                                  width: width * 0.85,
                                  child: Text(
                                    boardProvider.items[index].title!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Dongle',
                                      fontSize: 20,
                                      height: 1,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                SizedBox(
                                  width: width * 0.85,
                                  height: 40,
                                  child: Text(
                                    boardProvider.items[index].contents!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontFamily: 'Dongle',
                                      fontSize: 20,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: width * 0.85,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        child: Icon(
                                          Icons.thumb_up_alt_outlined,
                                          size: 15,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 2, top: 3),
                                        child: Text(
                                          boardProvider.items[index].postLike
                                              .toString(),
                                          style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                            height: 1,
                                            fontFamily: 'Dongle',
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            const EdgeInsets.only(left: 13),
                                        child: const Icon(
                                          Icons.chat_bubble_outline_rounded,
                                          size: 15,
                                          color: Color(0xFF9F7BFF),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 2, top: 3),
                                        child: Text(
                                          boardProvider.items[index].postComment
                                              .toString(),
                                          style: const TextStyle(
                                            color: Color(0xFF9F7BFF),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                            height: 1,
                                            fontFamily: 'Dongle',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  width: width * 0.85,
                                  child: Row(
                                    children: [
                                      Text(
                                        boardProvider.items[index].writer!,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          color:
                                              Color.fromARGB(255, 80, 80, 80),
                                          height: 1,
                                          fontFamily: 'Dongle',
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                        child: Text(
                                          "|",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                            color: Color.fromARGB(
                                                255, 120, 120, 120),
                                            height: 1,
                                            fontFamily: 'Dongle',
                                          ),
                                        ),
                                      ),
                                      Text(
                                        //boardProvider.items[index].date!,
                                        DateFormat("yyyy-MM-dd").format(date),
                                        style: const TextStyle(
                                          fontSize: 17,
                                          color:
                                              Color.fromARGB(255, 80, 80, 80),
                                          height: 1,
                                          fontFamily: 'Dongle',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  indent: 10,
                                  endIndent: 10,
                                  height: 1,
                                ),
                              ],
                            ),

                            // images
                            Align(
                              alignment: Alignment.topRight,
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  if (boardProvider.items[index].images !=
                                          null &&
                                      boardProvider
                                          .items[index].images!.isNotEmpty &&
                                      boardProvider.items[index].images![0] !=
                                          "null")
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 12, right: 15),
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(boardProvider
                                              .items[index].images![0].image!
                                              .toString()),
                                          fit: BoxFit
                                              .contain, // 이미지가 Container에 맞게 조절될 수 있도록 함
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.grey[200],
                                      ),
                                    ),

                                  // 게시글 사진 수
                                  Container(
                                    height: 20,
                                    width: 20,
                                    margin: const EdgeInsets.only(
                                        right: 20, bottom: 3),
                                    decoration: BoxDecoration(
                                      //color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.zero,
                                          margin: EdgeInsets.zero,
                                          decoration: const BoxDecoration(
                                            color: Colors.white70,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: boardProvider.items[index]
                                                        .images!.length <=
                                                    1
                                                ? null
                                                : Text(
                                                    boardProvider.items[index]
                                                        .images!.length
                                                        .toString(),
                                                    style: const TextStyle(
                                                      color: Colors.black45,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 20,
                                                      fontFamily: 'Dongle',
                                                      height: 1,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                //}
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WriteScreen(
                    userId: currentUserId,
                    userEmail: currentUserEmail,
                    createdDate: currentCreatedDate,
                  ),
                ),
              );
            },
            heroTag: "actionButton",
            backgroundColor: const Color.fromARGB(255, 136, 114, 209),
            child: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      ),
    );
  }
}
