import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/comments.dart';
import 'package:myapp/models/image.dart';
import 'package:myapp/models/like.dart';
import 'package:myapp/providers/comment_provider.dart';
import 'package:myapp/providers/post_provider.dart';
import 'package:myapp/screens/PhotoViewScreen.dart';
import 'package:myapp/screens/updateScreen.dart';
import 'package:myapp/service/getUuid.dart';
import 'package:myapp/service/notification.dart';
import 'package:myapp/widget/toastMessage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailScreen extends StatefulWidget {
  // 생성자 초기화
  final dynamic content;
  final Map<String, String> userInfo;
  // const DetailScreen({super.key, required this.content});
  static const routeName = '/detail';
  const DetailScreen(
      {super.key, required this.content, required this.userInfo});

  @override
  // State<DetailScreen> createState() => DetailState(content: content);
  State<DetailScreen> createState() =>
      DetailState(content: content, userInfo: userInfo);
}

class DetailState extends State<DetailScreen> {
  // 부모에게 받은 생성자 값 초기화
  final dynamic content;
  final Map<String, String> userInfo;
  DetailState({required this.content, required this.userInfo});

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      /// 컨트롤러가 SingleChildScrollView에 연결이 됐는지 안돼는지
      _scrollController.hasClients;
    });
    _loadUserInfo();
    likeCheck();
    print(content.postId);
    //loadImages(content);
  }

  late ScrollController _scrollController;
  final ScrollController _imageScrollController = ScrollController();
  final TextEditingController commentController = TextEditingController();
  final TextEditingController recommentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final FocusNode _commentFocusNode = FocusNode();
  final FocusNode _rommentFocusNode = FocusNode();

  bool isLoading = false;
  // bool isComment = false;
  // bool isDelete = false;
  bool isRecomment = false;
  bool isLike = false;
  String parent = '';

  late Comment comment;
  late Comment recomment;
  late Likes likes;

  // user info data
  String? currentUserEmail = '';
  String? currentUserCreatedDate = '';
  String? currentUserId = '';

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
        currentUserCreatedDate = prefs.getString('createdDate')!;
        currentUserId = prefs.getString('userId')!;
      }
      // not auto login(not exist SharedPreferences date)
      else {
        currentUserEmail = widget.userInfo['userEmail'];
        currentUserCreatedDate = widget.userInfo['userCreatedDate'];
        currentUserId = widget.userInfo['userId'];
      }
    });
    // setState(() {
    //   currentUserEmail = prefs.getString('userEmail');
    //   currentUserCreatedDate = prefs.getString('createdDate');
    //   currentUserId = prefs.getString('userId');
    // });
  }

  Future<void> likeCheck() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('likes')
          .where('postId', isEqualTo: content.postId)
          .where('userId', isEqualTo: userId)
          .get();
      if (querySnapshot.docs.isEmpty) {
        // 사용자가 해당 포스트를 좋아요하지 않았음
        isLike = false;
      } else {
        // 사용자가 해당 포스트를 좋아요 했음
        isLike = true;
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _refreshPosts() async {
    await Provider.of<PostProvider>(context, listen: false)
        .fetchItems(content.postId);
    await Provider.of<CommentProvider>(context, listen: false)
        .fetchItems(content.postId);
  }

  void deleteItemEvent(String? postId, List<Images> list) async {
    try {
      setState(() {
        isLoading = true;
      });

      Provider.of<PostProvider>(context, listen: false)
          .deletePost(content.postId!, list);

      ToastWidget.showToast('글이 삭제되었습니다.');

      Navigator.pop(context);
    } catch (e) {
      print(e);
      ToastWidget.showToast('알 수 없는 오류가 발생했습니다. 잠시 후에 다시 시도해주세요.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    var commentProvider = Provider.of<CommentProvider>(context);
    var postProvider = Provider.of<PostProvider>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          isRecomment = false;
        });
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(
                color: Colors.white,
                size: 26.0,
              ),
              centerTitle: true,
              backgroundColor: const Color(0xFF9F7BFF),
              title: const Text(
                "자유게시판",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  fontFamily: 'Dongle',
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
              actions: content.writer! == currentUserEmail
                  ? <Widget>[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        iconSize: 24,
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext dialogcontext) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  title: const Padding(
                                    padding: EdgeInsets.only(bottom: 15.0),
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      '알림',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 27,
                                        fontFamily: 'Dongle',
                                      ),
                                    ),
                                  ),
                                  content: const Text(
                                    '글을 수정하시겠습니까?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 25,
                                      fontFamily: 'Dongle',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text(
                                        '취소',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          fontFamily: 'Dongle',
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(dialogcontext).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text(
                                        '확인',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          fontFamily: 'Dongle',
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.of(dialogcontext).pop();

                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            // 정의한 ContentPage의 폼 호출
                                            builder: (context) => UpdateScreen(
                                                content: content,
                                                images: postProvider
                                                    .items[0].images!),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext dialogcontext) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  title: const Padding(
                                    padding: EdgeInsets.only(bottom: 15.0),
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      '알림',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 27,
                                        fontFamily: 'Dongle',
                                      ),
                                    ),
                                  ),
                                  content: const Text(
                                    '글을 삭제하시겠습니까?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 25,
                                      fontFamily: 'Dongle',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text(
                                        '취소',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          fontFamily: 'Dongle',
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(dialogcontext).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text(
                                        '확인',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          fontFamily: 'Dongle',
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.of(dialogcontext).pop();
                                        deleteItemEvent(content.postId!,
                                            postProvider.items[0].images!);
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                        iconSize: 24,
                        icon: const Icon(Icons.delete),
                      ),
                    ]
                  : null,
            ),
            body: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF9F7BFF)),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await _refreshPosts();
                    },
                    child: ScrollConfiguration(
                      behavior:
                          const ScrollBehavior().copyWith(overscroll: false),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            FutureBuilder(
                              future: postProvider.fetchItems(content.postId),
                              builder: (context, snapshot) {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  // physics:
                                  //     const AlwaysScrollableScrollPhysics(),
                                  itemCount: postProvider.items.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    DateTime date = DateTime.parse(
                                        postProvider.items[index].date!);
                                    return Column(
                                      children: [
                                        ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 15, vertical: 5),
                                          title: Text(
                                            postProvider.items[index].title!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 28,
                                              fontFamily: 'Dongle',
                                              height: 1.2,
                                            ),
                                          ),
                                          subtitle: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 3),
                                            child: Text(
                                              "${postProvider.items[index].writer!}  ${DateFormat("yyyy-MM-dd").format(date)}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22,
                                                fontFamily: 'Dongle',
                                                height: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Divider(
                                          indent: 10,
                                          endIndent: 10,
                                          height: 1,
                                          color: Color.fromARGB(
                                              255, 122, 122, 122),
                                        ),
                                        // content
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 18.0,
                                              right: 18.0,
                                              top: 23,
                                              bottom: 20,
                                            ),
                                            child: Text(
                                              postProvider
                                                  .items[index].contents!,
                                              style: const TextStyle(
                                                fontSize: 28,
                                                fontFamily: 'Dongle',
                                                height: 1,
                                              ),
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                        ),

                                        // images
                                        if (postProvider
                                            .items[0].images!.isNotEmpty)
                                          Container(
                                            height: 190,
                                            width: double.infinity,
                                            margin: const EdgeInsets.all(10),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Scrollbar(
                                              controller:
                                                  _imageScrollController,
                                              thickness: 5,
                                              radius:
                                                  const Radius.circular(15.0),
                                              child: GridView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount:
                                                      1, // 한 줄에 표시될 이미지 수
                                                ),
                                                itemCount: postProvider
                                                    .items[0].images!.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (context) {
                                                            return PhotoViewScreen(
                                                              imagePaths:
                                                                  postProvider
                                                                      .items[0]
                                                                      .images!,
                                                              currentIndex:
                                                                  index,
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Container(
                                                        width: 190, // 이미지의 너비
                                                        height: 190,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          color:
                                                              Colors.grey[200],
                                                          image:
                                                              DecorationImage(
                                                            fit: BoxFit.contain,
                                                            image: NetworkImage(
                                                              postProvider
                                                                  .items[0]
                                                                  .images![
                                                                      index]
                                                                  .image!,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),

                                        // 좋아요 버튼
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 15, top: 10, bottom: 5),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                // backgroundColor: isLike
                                                //     ? const Color(0xFF9F7BFF)
                                                //     : const Color.fromARGB(255, 241, 236, 253),
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 248, 248, 248),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 17),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                side: const BorderSide(
                                                  color: Color.fromARGB(
                                                      193, 224, 224, 224),
                                                ),
                                              ),
                                              label: Container(
                                                margin: const EdgeInsets.only(
                                                    top: 4),
                                                child: Text(
                                                  postProvider
                                                      .items[index].postLike!
                                                      .toString(),
                                                  style: TextStyle(
                                                    // color: isLike
                                                    //     ? Colors.white
                                                    //     : const Color.fromARGB(
                                                    //         255, 116, 116, 116),
                                                    color: isLike
                                                        ? Colors.red
                                                        : const Color.fromARGB(
                                                            255, 116, 116, 116),
                                                    //color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 26,
                                                    fontFamily: 'Dongle',
                                                    height: 1,
                                                  ),
                                                ),
                                              ),
                                              //padding: const EdgeInsets.all(0.0),
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                        dialogcontext) {
                                                      return AlertDialog(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        backgroundColor:
                                                            Colors.white,
                                                        title: const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  bottom: 15.0),
                                                          child: Text(
                                                            textAlign: TextAlign
                                                                .center,
                                                            '알림',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 27,
                                                              fontFamily:
                                                                  'Dongle',
                                                            ),
                                                          ),
                                                        ),
                                                        content: isLike
                                                            ? const Text(
                                                                '좋아요를 취소하시겠습니까?',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 25,
                                                                  fontFamily:
                                                                      'Dongle',
                                                                ),
                                                              )
                                                            : const Text(
                                                                '좋아요를 누르시겠습니까?',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 25,
                                                                  fontFamily:
                                                                      'Dongle',
                                                                ),
                                                              ),
                                                        actions: [
                                                          TextButton(
                                                            child: const Text(
                                                              '취소',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 24,
                                                                fontFamily:
                                                                    'Dongle',
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      dialogcontext)
                                                                  .pop();
                                                            },
                                                          ),
                                                          TextButton(
                                                            child: const Text(
                                                              '확인',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 24,
                                                                fontFamily:
                                                                    'Dongle',
                                                              ),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              Navigator.of(
                                                                      dialogcontext)
                                                                  .pop();
                                                              setState(() {
                                                                isLoading =
                                                                    true;
                                                              });

                                                              // 이미 좋아요 했으면 좋아요 취소
                                                              if (isLike) {
                                                                await Provider.of<
                                                                            PostProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .postDislike(
                                                                  content
                                                                      .postId!,
                                                                  currentUserId!,
                                                                );
                                                                ToastWidget
                                                                    .showToast(
                                                                        '좋아요 취소...');
                                                                await likeCheck();
                                                              }
                                                              // 아니면 게시글 좋아요
                                                              else {
                                                                likes = Likes(
                                                                    postId: content
                                                                        .postId,
                                                                    userId:
                                                                        currentUserId,
                                                                    userEmail:
                                                                        currentUserEmail);

                                                                await Provider.of<
                                                                            PostProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .postLike(
                                                                        currentUserId!,
                                                                        content
                                                                            .postId!,
                                                                        likes);
                                                                ToastWidget
                                                                    .showToast(
                                                                        '좋아요!');
                                                                await likeCheck();
                                                              }

                                                              setState(() {
                                                                isLoading =
                                                                    false;
                                                              });
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    });
                                              },
                                              icon: Icon(
                                                Icons.thumb_up_alt,
                                                //color: Colors.red,
                                                color: isLike
                                                    ? Colors.red
                                                    : const Color.fromARGB(
                                                        255, 116, 116, 116),
                                                size: 19,
                                              ),
                                            ),
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, bottom: 5, top: 10),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 3.5),
                                                  child: Icon(
                                                    Icons.chat_rounded,
                                                    color: Color.fromARGB(
                                                        255, 116, 116, 116),
                                                    size: 17,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                const Text(
                                                  '댓글',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 116, 116, 116),
                                                    fontFamily: 'Dongle',
                                                    fontSize: 22,
                                                    height: 1,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 5),
                                                  child: Text(
                                                    '${commentProvider.items.length}',
                                                    style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 116, 116, 116),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Dongle',
                                                      fontSize: 27,
                                                      height: 0.1,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        const Padding(
                                          padding: EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          child: Divider(
                                            indent: 10,
                                            endIndent: 10,
                                            height: 1,
                                            color: Color.fromARGB(
                                                255, 122, 122, 122),
                                          ),
                                        ),

                                        FutureBuilder(
                                          future: _refreshPosts(),
                                          builder: (context, snapshot) {
                                            commentProvider =
                                                Provider.of<CommentProvider>(
                                                    context);

                                            if (commentProvider.items.isEmpty) {
                                              return const Center(
                                                child: SizedBox(
                                                  height: 200,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 90),
                                                    child: Text(
                                                      "댓글이 없습니다.",
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontFamily: 'Dongle',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              if (commentProvider
                                                      .items.length ==
                                                  0) {
                                                return const Center(
                                                  child: SizedBox(
                                                    height: 200,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 90),
                                                      child: Text(
                                                        "댓글이 없습니다.",
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontFamily: 'Dongle',
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              return ListView.builder(
                                                //primary: false,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: commentProvider
                                                    .items.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  if (commentProvider
                                                          .items[index].depth ==
                                                      0) {
                                                    return Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 0),
                                                          child: index == 0
                                                              ? null
                                                              : const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .only(
                                                                              top: 8.0),
                                                                  child:
                                                                      Divider(
                                                                    height: 1,
                                                                    endIndent:
                                                                        10,
                                                                    indent: 20,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            122,
                                                                            122,
                                                                            122),
                                                                  ),
                                                                ),
                                                        ),
                                                        Container(
                                                          width: width * 0.85,
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 15),
                                                          child: Row(
                                                            children: [
                                                              commentProvider
                                                                          .items[
                                                                              index]
                                                                          .commentWriter ==
                                                                      content
                                                                          .writer
                                                                  ? Text(
                                                                      "${commentProvider.items[index].commentWriter!} (글쓴이)",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            93,
                                                                            44,
                                                                            228),
                                                                        fontFamily:
                                                                            'Dongle',
                                                                        fontSize:
                                                                            20,
                                                                        height:
                                                                            1,
                                                                      ),
                                                                    )
                                                                  : Text(
                                                                      commentProvider
                                                                          .items[
                                                                              index]
                                                                          .commentWriter
                                                                          .toString(),
                                                                      //currentUserEmail!,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontFamily:
                                                                            'Dongle',
                                                                        fontSize:
                                                                            20,
                                                                        height:
                                                                            1,
                                                                      ),
                                                                    ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                commentProvider
                                                                    .items[
                                                                        index]
                                                                    .date!,
                                                                style:
                                                                    const TextStyle(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          122,
                                                                          122,
                                                                          122),
                                                                  fontFamily:
                                                                      'Dongle',
                                                                  fontSize: 15,
                                                                  height: 1,
                                                                ),
                                                              ),
                                                              const Spacer(),
                                                              SizedBox(
                                                                height: 18,
                                                                width: 18,
                                                                child:
                                                                    IconButton(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          0.0),
                                                                  onPressed:
                                                                      () async {
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return AlertDialog(
                                                                          backgroundColor:
                                                                              Colors.white,
                                                                          shape:
                                                                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                          title:
                                                                              const Padding(
                                                                            padding:
                                                                                EdgeInsets.only(bottom: 15.0),
                                                                            child:
                                                                                Text(
                                                                              textAlign: TextAlign.center,
                                                                              '알림',
                                                                              style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 27,
                                                                                fontFamily: 'Dongle',
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          content:
                                                                              const Text(
                                                                            '대댓글을 작성하시겠습니까?',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 25,
                                                                              fontFamily: 'Dongle',
                                                                            ),
                                                                          ),
                                                                          actions: [
                                                                            TextButton(
                                                                              child: const Text(
                                                                                '취소',
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontSize: 24,
                                                                                  fontFamily: 'Dongle',
                                                                                ),
                                                                              ),
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                            ),
                                                                            TextButton(
                                                                              child: const Text(
                                                                                '확인',
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontSize: 24,
                                                                                  fontFamily: 'Dongle',
                                                                                ),
                                                                              ),
                                                                              onPressed: () {
                                                                                setState(() {
                                                                                  // parentId = commentProvider
                                                                                  //     .items[
                                                                                  //         index]
                                                                                  //     .commentId!;
                                                                                  parent = commentProvider.items[index].parent!;
                                                                                  isRecomment = true;
                                                                                  _rommentFocusNode.requestFocus();
                                                                                });

                                                                                Navigator.of(context).pop();
                                                                              },
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                  icon:
                                                                      const Icon(
                                                                    Icons
                                                                        .chat_bubble,
                                                                    size: 18,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            116,
                                                                            116,
                                                                            116),
                                                                  ),
                                                                ),
                                                              ),
                                                              // const SizedBox(
                                                              //   width: 10,
                                                              // ),
                                                              if (commentProvider
                                                                      .items[
                                                                          index]
                                                                      .commentWriter ==
                                                                  currentUserEmail)
                                                                Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                    left: 10,
                                                                  ),
                                                                  height: 20,
                                                                  width: 20,
                                                                  child:
                                                                      IconButton(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            0.0),
                                                                    onPressed:
                                                                        () async {
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                dialogcontext) {
                                                                          return AlertDialog(
                                                                            backgroundColor:
                                                                                Colors.white,
                                                                            shape:
                                                                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                            title:
                                                                                const Padding(
                                                                              padding: EdgeInsets.only(bottom: 15.0),
                                                                              child: Text(
                                                                                textAlign: TextAlign.center,
                                                                                '알림',
                                                                                style: TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontSize: 27,
                                                                                  fontFamily: 'Dongle',
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            content:
                                                                                const Text(
                                                                              '댓글을 삭제하시겠습니까?',
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: 25,
                                                                                fontFamily: 'Dongle',
                                                                              ),
                                                                            ),
                                                                            actions: [
                                                                              TextButton(
                                                                                child: const Text(
                                                                                  '취소',
                                                                                  style: TextStyle(
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 24,
                                                                                    fontFamily: 'Dongle',
                                                                                  ),
                                                                                ),
                                                                                onPressed: () {
                                                                                  Navigator.of(dialogcontext).pop();
                                                                                },
                                                                              ),
                                                                              TextButton(
                                                                                child: const Text(
                                                                                  '확인',
                                                                                  style: TextStyle(
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 24,
                                                                                    fontFamily: 'Dongle',
                                                                                  ),
                                                                                ),
                                                                                onPressed: () async {
                                                                                  setState(() {
                                                                                    isLoading = true;
                                                                                  });
                                                                                  Navigator.of(dialogcontext).pop();
                                                                                  try {
                                                                                    // Delete post(with comments)
                                                                                    await commentProvider.deleteComment(commentProvider.items[index].parent!, commentProvider.items[index].postId!);
                                                                                    ToastWidget.showToast('댓글이 삭제되었습니다.');
                                                                                  } catch (e) {
                                                                                    print(e);
                                                                                    ToastWidget.showToast('알 수 없는 오류가 발생했습니다. 잠시 후에 다시 시도해주세요.');
                                                                                  } finally {
                                                                                    setState(() {
                                                                                      isLoading = false;
                                                                                    });
                                                                                  }
                                                                                },
                                                                              ),
                                                                            ],
                                                                          );
                                                                        },
                                                                      );
                                                                    },
                                                                    icon:
                                                                        const Icon(
                                                                      Icons
                                                                          .delete,
                                                                      size: 20,
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          116,
                                                                          116,
                                                                          116),
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 10,
                                                                  bottom: 15),
                                                          width: width * 0.85,
                                                          child: Text(
                                                            commentProvider
                                                                .items[index]
                                                                .comment!,
                                                            textAlign:
                                                                TextAlign.start,
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  'Dongle',
                                                              fontSize: 20,
                                                              height: 1,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  } else {
                                                    return Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 3,
                                                              left: 20,
                                                              right: 10,
                                                              bottom: 3),
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 5,
                                                              top: 5),
                                                      child: ChatBubble(
                                                        backGroundColor:
                                                            const Color
                                                                .fromARGB(255,
                                                                251, 234, 253),
                                                        clipper: ChatBubbleClipper5(
                                                            type: BubbleType
                                                                .receiverBubble),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                commentProvider
                                                                            .items[
                                                                                index]
                                                                            .commentWriter! ==
                                                                        content
                                                                            .writer
                                                                    ? Container(
                                                                        margin: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                5,
                                                                            left:
                                                                                10),
                                                                        child:
                                                                            Text(
                                                                          "${commentProvider.items[index].commentWriter!} (글쓴이)",
                                                                          style:
                                                                              const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                20,
                                                                            fontFamily:
                                                                                'Dongle',
                                                                            height:
                                                                                1,
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                93,
                                                                                44,
                                                                                228),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Container(
                                                                        margin: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                5,
                                                                            left:
                                                                                10),
                                                                        child:
                                                                            Text(
                                                                          commentProvider
                                                                              .items[index]
                                                                              .commentWriter!,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                20,
                                                                            fontFamily:
                                                                                'Dongle',
                                                                            height:
                                                                                1,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  commentProvider
                                                                      .items[
                                                                          index]
                                                                      .date!,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            122,
                                                                            122,
                                                                            122),
                                                                    fontSize:
                                                                        15,
                                                                    fontFamily:
                                                                        'Dongle',
                                                                    //height: 1,
                                                                  ),
                                                                ),
                                                                const Spacer(),
                                                                if (commentProvider
                                                                        .items[
                                                                            index]
                                                                        .commentWriter! ==
                                                                    currentUserEmail)
                                                                  SizedBox(
                                                                    width: 20,
                                                                    height: 20,
                                                                    child:
                                                                        IconButton(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          0.0),
                                                                      onPressed:
                                                                          () async {
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (BuildContext dialogcontext) {
                                                                            return AlertDialog(
                                                                              backgroundColor: Colors.white,
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                              title: const Padding(
                                                                                padding: EdgeInsets.only(bottom: 15.0),
                                                                                child: Text(
                                                                                  textAlign: TextAlign.center,
                                                                                  '알림',
                                                                                  style: TextStyle(
                                                                                    color: Colors.black,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 27,
                                                                                    fontFamily: 'Dongle',
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              content: const Text(
                                                                                '대댓글을 삭제하시겠습니까?',
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontSize: 25,
                                                                                  fontFamily: 'Dongle',
                                                                                ),
                                                                              ),
                                                                              actions: [
                                                                                TextButton(
                                                                                  child: const Text(
                                                                                    '취소',
                                                                                    style: TextStyle(
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: 24,
                                                                                      fontFamily: 'Dongle',
                                                                                    ),
                                                                                  ),
                                                                                  onPressed: () {
                                                                                    Navigator.of(dialogcontext).pop();
                                                                                  },
                                                                                ),
                                                                                TextButton(
                                                                                  child: const Text(
                                                                                    '확인',
                                                                                    style: TextStyle(
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: 24,
                                                                                      fontFamily: 'Dongle',
                                                                                    ),
                                                                                  ),
                                                                                  onPressed: () async {
                                                                                    setState(() {
                                                                                      isLoading = true;
                                                                                    });
                                                                                    Navigator.of(dialogcontext).pop();
                                                                                    try {
                                                                                      // Delete recomment
                                                                                      await commentProvider.deleteReComment(commentProvider.items[index].commentId!, commentProvider.items[index].postId!);
                                                                                      ToastWidget.showToast('대댓글이 삭제되었습니다.');
                                                                                    } catch (e) {
                                                                                      print(e);
                                                                                      ToastWidget.showToast('알 수 없는 오류가 발생했습니다. 잠시 후에 다시 시도해주세요.');
                                                                                    } finally {
                                                                                      setState(() {
                                                                                        isLoading = false;
                                                                                      });
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .delete,
                                                                        size:
                                                                            20,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            116,
                                                                            116,
                                                                            116),
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                            Container(
                                                              width:
                                                                  width * 0.95,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 10,
                                                                      bottom: 7,
                                                                      top: 10),
                                                              child: Text(
                                                                commentProvider
                                                                    .items[
                                                                        index]
                                                                    .comment!,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 20,
                                                                  fontFamily:
                                                                      'Dongle',
                                                                  height: 1,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            // Comment TextFormField in bottomNavigationBar
            bottomNavigationBar: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: SizedBox(
                height: 65.0,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Visibility(
                      visible: !isRecomment,
                      child: Container(
                        padding:
                            const EdgeInsets.only(left: 8, right: 8, top: 7),
                        color: Colors.purple[10],
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            focusNode: _commentFocusNode,
                            style: const TextStyle(
                              color: Color(0xFF393939),
                              fontSize: 23,
                              fontWeight: FontWeight.w400,
                              height: 1,
                              decorationThickness: 0,
                              fontFamily: 'Dongle',
                            ),
                            cursorHeight: 20,
                            controller: commentController,
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                ToastWidget.showToast('댓글을 입력해주세요.');
                                return '';
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: '댓글을 입력해주세요',
                              fillColor:
                                  const Color.fromARGB(255, 228, 228, 228),
                              filled: true,
                              hintStyle: const TextStyle(
                                color: Colors.black26,
                                fontFamily: 'Dongle',
                                height: 1,
                                fontSize: 23,
                              ),
                              errorStyle: const TextStyle(height: 0),
                              prefixIcon: Icon(
                                Icons.chat,
                                color: Colors.deepPurple[300],
                              ),
                              suffixIcon: IconButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext dialogcontext) {
                                          return AlertDialog(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            title: const Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 15.0),
                                              child: Text(
                                                textAlign: TextAlign.center,
                                                '알림',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 27,
                                                  fontFamily: 'Dongle',
                                                ),
                                              ),
                                            ),
                                            content: const Text(
                                              '댓글을 작성하시겠습니까?',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 25,
                                                fontFamily: 'Dongle',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text(
                                                  '취소',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                    fontFamily: 'Dongle',
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(dialogcontext)
                                                      .pop();
                                                },
                                              ),
                                              TextButton(
                                                child: const Text(
                                                  '확인',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                    fontFamily: 'Dongle',
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  // comment ID
                                                  String commentId =
                                                      GetUuid.getuuid();
                                                  // comment date
                                                  DateTime datetime =
                                                      DateTime.now();
                                                  // comment seq
                                                  var now =
                                                      DateTime.now().toString();
                                                  String seq = now.replaceAll(
                                                      RegExp('\\D'), "");

                                                  try {
                                                    setState(() {
                                                      isLoading = true;
                                                    });

                                                    Navigator.of(dialogcontext)
                                                        .pop();

                                                    //save comment to firestore database
                                                    comment = Comment(
                                                      postId: content.postId,
                                                      commentId: commentId,
                                                      comment: commentController
                                                          .text,
                                                      depth: 0,
                                                      seq: seq,
                                                      date: DateFormat(
                                                              'yyyy-MM-dd HH:mm:ss')
                                                          .format(datetime),
                                                      commentWriter:
                                                          currentUserEmail,
                                                      parent: seq,
                                                    );

                                                    FirebaseFirestore.instance
                                                        .collection('comments')
                                                        .doc(commentId)
                                                        .set(comment.toMap());

                                                    // comment cnt + 1
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('posts')
                                                        .doc(content.postId!)
                                                        .update({
                                                      "postComment":
                                                          FieldValue.increment(
                                                              1),
                                                    });

                                                    // comment fcm
                                                    if (postProvider
                                                            .items[0].writer !=
                                                        currentUserEmail) {
                                                      QuerySnapshot
                                                          querySnapshot =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'users')
                                                              .where('userId',
                                                                  isEqualTo: content
                                                                      .writerId)
                                                              .get();
                                                      // send fcm
                                                      String userToken =
                                                          querySnapshot.docs[0]
                                                              ['token'];
                                                      sendNotificationToDevice(
                                                          userToken,
                                                          "새로운 댓글이 달렸습니다.",
                                                          commentController
                                                              .text,
                                                          content);
                                                    }

                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 500),
                                                        () {
                                                      _scrollController.animateTo(
                                                          1200,
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      1000),
                                                          curve: Curves
                                                              .fastOutSlowIn);
                                                    });

                                                    setState(() {
                                                      isLoading = false;
                                                      commentController.clear();
                                                      ToastWidget.showToast(
                                                          '댓글 작성이 완료되었습니다.');
                                                    });
                                                  } catch (e) {
                                                    print(e);
                                                    ToastWidget.showToast(
                                                        '알 수 없는 오류가 발생했습니다. 잠시 후에 다시 시도해주세요.');
                                                    setState(() {
                                                      isLoading = false;
                                                      //ToastWidget.showToast('글 작성이 완료되었습니다.');
                                                    });
                                                  } finally {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                  }
                                                },
                                              ),
                                            ],
                                          );
                                        });
                                  } else {
                                    null;
                                  }
                                },
                                icon: Icon(
                                  Icons.send,
                                  color: Colors.deepPurple[300],
                                ),
                              ),
                              disabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Color(0xFF837E93),
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Color(0xFF837E93),
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                  width: 1.5,
                                  color: Color(0xFF9F7BFF),
                                ),
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                  width: 1.5,
                                  color: Color.fromARGB(255, 255, 123, 123),
                                ),
                              ),
                              focusedErrorBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                  width: 1.5,
                                  color: Color.fromARGB(255, 255, 123, 123),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 대댓글 입력창
                    Visibility(
                      visible: isRecomment,
                      child: Container(
                        padding:
                            const EdgeInsets.only(left: 8, right: 8, top: 7),
                        color: Colors.purple[10],
                        child: Form(
                          key: _formKey,
                          child: Focus(
                            onFocusChange: (hasFocus) {
                              if (hasFocus) {
                                // do stuff
                                setState(() {
                                  isRecomment = true;
                                });
                              } else {
                                setState(() {
                                  isRecomment = false;
                                });
                              }
                            },
                            child: TextFormField(
                              focusNode: _rommentFocusNode,
                              style: const TextStyle(
                                color: Color(0xFF393939),
                                fontSize: 23,
                                fontWeight: FontWeight.w400,
                                height: 1,
                                decorationThickness: 0,
                                fontFamily: 'Dongle',
                              ),
                              cursorHeight: 20,
                              controller: recommentController,
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  ToastWidget.showToast('대댓글을 입력해주세요.');
                                  return '';
                                }

                                return null;
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: '대댓글을 입력해주세요',
                                fillColor:
                                    const Color.fromARGB(255, 228, 228, 228),
                                filled: true,
                                hintStyle: const TextStyle(
                                  color: Colors.black26,
                                  fontFamily: 'Dongle',
                                  height: 1,
                                  fontSize: 23,
                                ),
                                errorStyle: const TextStyle(height: 0),
                                prefixIcon: Icon(
                                  Icons.chat,
                                  color: Colors.deepPurple[300],
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      showDialog(
                                          context: context,
                                          builder:
                                              (BuildContext dialogcontext) {
                                            return AlertDialog(
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              title: const Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 15.0),
                                                child: Text(
                                                  textAlign: TextAlign.center,
                                                  '알림',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 27,
                                                    fontFamily: 'Dongle',
                                                  ),
                                                ),
                                              ),
                                              content: const Text(
                                                '대댓글을 작성하시겠습니까?',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 25,
                                                  fontFamily: 'Dongle',
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: const Text(
                                                    '취소',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 24,
                                                      fontFamily: 'Dongle',
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(dialogcontext)
                                                        .pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text(
                                                    '확인',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 24,
                                                      fontFamily: 'Dongle',
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    // Recomment ID
                                                    String recommentId =
                                                        GetUuid.getuuid();
                                                    // Recomment date
                                                    DateTime datetime =
                                                        DateTime.now();
                                                    // Recomment seq
                                                    var now = DateTime.now()
                                                        .toString();
                                                    String seq = now.replaceAll(
                                                        RegExp('\\D'), "");
                                                    try {
                                                      setState(() {
                                                        isLoading = true;
                                                      });

                                                      Navigator.of(
                                                              dialogcontext)
                                                          .pop();

                                                      //save comment to firestore database
                                                      recomment = Comment(
                                                        postId: content.postId,
                                                        commentId: recommentId,
                                                        comment:
                                                            recommentController
                                                                .text,
                                                        depth: 1,
                                                        seq: seq,
                                                        date: DateFormat(
                                                                'yyyy-MM-dd HH:mm:ss')
                                                            .format(datetime),
                                                        commentWriter:
                                                            currentUserEmail,
                                                        parent: parent,
                                                      );

                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'comments')
                                                          .doc(recommentId)
                                                          .set(recomment
                                                              .toMap());

                                                      // comment cnt + 1
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('posts')
                                                          .doc(content.postId!)
                                                          .update({
                                                        "postComment":
                                                            FieldValue
                                                                .increment(1),
                                                      });

                                                      // recomment fcm
                                                      if (postProvider.items[0]
                                                              .writer !=
                                                          currentUserEmail) {
                                                        QuerySnapshot
                                                            querySnapshot =
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .where('userId',
                                                                    isEqualTo:
                                                                        content
                                                                            .writerId)
                                                                .get();
                                                        String userToken =
                                                            querySnapshot
                                                                    .docs[0]
                                                                ['token'];
                                                        sendNotificationToDevice(
                                                            userToken,
                                                            "새로운 대댓글이 달렸습니다.",
                                                            recommentController
                                                                .text,
                                                            content);
                                                      }

                                                      Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                                  500), () {
                                                        _scrollController.animateTo(
                                                            1200,
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        1000),
                                                            curve: Curves
                                                                .fastOutSlowIn);
                                                      });

                                                      setState(() {
                                                        isLoading = false;
                                                        recommentController
                                                            .clear();
                                                        ToastWidget.showToast(
                                                            '대댓글 작성이 완료되었습니다.');
                                                      });
                                                    } catch (e) {
                                                      print(e);
                                                      ToastWidget.showToast(
                                                          '알 수 없는 오류가 발생했습니다. 잠시 후에 다시 시도해주세요.');
                                                      setState(() {
                                                        isLoading = false;
                                                        //ToastWidget.showToast('글 작성이 완료되었습니다.');
                                                      });
                                                    } finally {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                    }
                                                  },
                                                ),
                                              ],
                                            );
                                          });
                                    } else {
                                      null;
                                    }
                                  },
                                  icon: Icon(
                                    Icons.send,
                                    //color: Color(0xFF9F7BFF),
                                    color: Colors.deepPurple[300],
                                  ),
                                ),
                                disabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Color(0xFF837E93),
                                  ),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Color(0xFF837E93),
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                    width: 1.5,
                                    color: Color(0xFF9F7BFF),
                                  ),
                                ),
                                errorBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                    width: 1.5,
                                    color: Color.fromARGB(255, 255, 123, 123),
                                  ),
                                ),
                                focusedErrorBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                    width: 1.5,
                                    color: Color.fromARGB(255, 255, 123, 123),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tasking
          if (isLoading)
            const Opacity(
              opacity: 0.6,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9F7BFF)),
              ),
            ),
        ],
      ),
    );
  }
}
