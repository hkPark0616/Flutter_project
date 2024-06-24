import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/board.dart';
import 'package:myapp/models/image.dart';
import 'package:myapp/screens/boardScreen.dart';
import 'package:myapp/service/getUuid.dart';
import 'package:myapp/widget/toastMessage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WriteScreen extends StatefulWidget {
  final String? userId;
  final String? userEmail;
  final String? createdDate;

  const WriteScreen({
    super.key,
    required this.userId,
    required this.userEmail,
    required this.createdDate,
  });

  @override
  State<WriteScreen> createState() => WriteState();
}

class WriteState extends State<WriteScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isLoading = false;

  String title = '';
  String content = '';
  String postId = '';

  late Board post;
  DateTime datetime = DateTime.now();

  final picker = ImagePicker(); // ImagePicker
  XFile? image; // 카메라로 촬영한 이미지를 저장할 변수
  List<XFile?> multiImage = []; // 갤러리에서 여러 장의 사진을 선택해서 저장할 변수
  List<XFile?> images = []; // 가져온 사진들을 보여주기 위한 변수

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  // 아이디와 비밀번호 정보
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // user info data
  String currentUserEmail = '';
  String currentCreatedDate = '';
  String currentUserId = '';

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
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            //elevation: 0.7,
            backgroundColor: const Color(0xFF9F7BFF),
            title: const Text(
              '글 작성',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                  fontFamily: 'Dongle',
                  color: Colors.white),
            ),
            iconTheme: const IconThemeData(
              color: Colors.white,
              size: 28,
            ),
            centerTitle: true,

            actions: [
              Container(
                padding: const EdgeInsets.only(right: 5.0),
                child: TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
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
                              '글을 작성하시겠습니까?',
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
                                  // get postid(uuid)
                                  postId = GetUuid.getuuid();

                                  try {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    Navigator.of(dialogcontext).pop();

                                    // save images to firebase storage
                                    for (int i = 0; i < images.length; i++) {
                                      Uint8List bytes =
                                          await images[i]!.readAsBytes();

                                      // storage
                                      String storagePath =
                                          'images/$postId/image_$i';
                                      // firestore database
                                      // String _imageRef =
                                      //     'images/$postId/image_$i';
                                      await FirebaseStorage.instance
                                          .ref(storagePath)
                                          .putData(
                                            bytes,
                                            SettableMetadata(
                                              contentType: "image/png",
                                            ),
                                          );

                                      final String _urlString =
                                          await FirebaseStorage.instance
                                              .ref(storagePath)
                                              .getDownloadURL();

                                      // Firestore에 이미지 데이터 저장
                                      await FirebaseFirestore.instance
                                          .collection('posts')
                                          .doc(postId)
                                          .collection('images')
                                          .add(
                                            Images(
                                              image: _urlString,
                                              path: storagePath,
                                              postId: postId,
                                              //bytes: bytes,
                                            ).toMap(),
                                          );
                                    }

                                    //save post to firestore database
                                    post = Board(
                                      postId: postId,
                                      title: titleController.text,
                                      contents: contentController.text,
                                      date: DateFormat('yyyy-MM-dd HH:mm:ss')
                                          .format(datetime),
                                      writer: currentUserEmail,
                                      writerId: currentUserId,
                                      postLike: 0,
                                      postComment: 0,
                                    );

                                    FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(postId)
                                        .set(post.toMap());

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BoardScreen(
                                          userEmail: widget.userEmail,
                                          userId: widget.userId,
                                          createdDate: widget.createdDate,
                                        ),
                                      ),
                                    );

                                    setState(() {
                                      isLoading = false;
                                      ToastWidget.showToast('글 작성이 완료되었습니다.');
                                    });
                                  } catch (e) {
                                    print(e);
                                    ToastWidget.showToast(
                                        '알 수 없는 오류가 발생했습니다. 잠시 후에 다시 시도해주세요.');
                                    setState(() {
                                      isLoading = false;
                                      //ToastWidget.showToast('글 작성이 완료되었습니다.');
                                    });
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: const Text(
                    '완료',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Dongle',
                      height: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: titleController,
                        style: const TextStyle(
                          color: Color(0xFF393939),
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                          height: 1,
                          decorationThickness: 0,
                          fontFamily: 'Dongle',
                        ),
                        cursorHeight: 25,
                        decoration: const InputDecoration(
                          alignLabelWithHint: true,
                          labelText: '제목',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 97, 97, 97),
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Dongle',
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Color.fromARGB(255, 97, 97, 97),
                            fontSize: 27,
                            fontFamily: 'Dongle',
                            height: 1,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                          errorStyle: TextStyle(
                            fontFamily: 'Dongle',
                            fontSize: 20,
                            height: 0.5,
                          ),
                          contentPadding: EdgeInsets.only(bottom: 10),
                        ),
                        onSaved: (value) => title = value!,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return '제목을 입력해주세요.';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: contentController,
                        style: const TextStyle(
                          color: Color(0xFF393939),
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                          height: 1,
                          decorationThickness: 0,
                          fontFamily: 'Dongle',
                        ),
                        cursorHeight: 25,
                        textAlign: TextAlign.start,
                        decoration: const InputDecoration(
                          alignLabelWithHint: true,
                          labelText: '내용',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 97, 97, 97),
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Dongle',
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Color.fromARGB(255, 97, 97, 97),
                            fontSize: 27,
                            fontFamily: 'Dongle',
                            height: 1,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                          errorStyle: TextStyle(
                            fontFamily: 'Dongle',
                            fontSize: 20,
                            height: 0.5,
                          ),
                          contentPadding: EdgeInsets.only(bottom: 10),
                        ),
                        maxLines: 15,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        onSaved: (value) => content = value!,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return '내용을 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                    ),

                    //카메라로 촬영하기
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            height: 50,
                            child: const Text(
                              "사진 업로드",
                              //textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Dongle',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: Color.fromARGB(255, 97, 97, 97),
                                  height: 1),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 136, 114, 209),
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 0.5,
                                  blurRadius: 5,
                                )
                              ],
                            ),
                            child: IconButton(
                              onPressed: () async {
                                if (await Permission.camera
                                    .request()
                                    .isDenied) {
                                  await Permission.camera.request();
                                } else {
                                  image = await picker.pickImage(
                                    source: ImageSource.camera,
                                    // maxWidth: 640,
                                    // maxHeight: 280,
                                    imageQuality: 100,
                                  );
                                  //카메라로 촬영하지 않고 뒤로가기 버튼을 누를 경우, null값이 저장되므로 if문을 통해 null이 아닐 경우에만 images변수로 저장하도록 합니다
                                  if (image != null) {
                                    setState(() {
                                      images.add(image);
                                    });
                                  }
                                }
                              },
                              icon: const Icon(
                                Icons.add_a_photo,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          //갤러리에서 가져오기
                          Container(
                            margin: const EdgeInsets.only(right: 10, left: 5),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 136, 114, 209),
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 0.5,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () async {
                                multiImage = await picker.pickMultiImage(
                                  // maxWidth: 640,
                                  // maxHeight: 280,
                                  imageQuality: 100,
                                );
                                setState(() {
                                  //multiImage를 통해 갤러리에서 가지고 온 사진들은 리스트 변수에 저장되므로 addAll()을 사용해서 images와 multiImage 리스트를 합쳐줍니다.
                                  images.addAll(multiImage);
                                });
                              },
                              icon: const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 업로드 사진 리스트
                    Container(
                      height: 150,
                      width: double.infinity,
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Scrollbar(
                        controller: _scrollController,
                        thickness: 5,
                        radius: const Radius.circular(15.0),
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal, // 횡스크롤 리스트 설정
                          padding: const EdgeInsets.all(0),
                          itemCount: images
                              .length, // 보여줄 item 개수. images 리스트 변수에 담겨있는 사진 수 만큼.
                          itemBuilder: (BuildContext context, int index) {
                            // 사진 오른 쪽 위 삭제 버튼을 표시하기 위해 Stack을 사용함
                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  width: 150, // 이미지의 너비
                                  height: 150,
                                  margin: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    image: DecorationImage(
                                      fit: BoxFit.contain,
                                      image: FileImage(
                                        File(images[index]!
                                            .path), // images 리스트 변수 안에 있는 사진들을 순서대로 표시함
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 30,
                                  height: 30,
                                  margin:
                                      const EdgeInsets.only(right: 10, top: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  // 삭제 버튼
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.close,
                                        color: Colors.white, size: 15),
                                    onPressed: () {
                                      // 버튼을 누르면 해당 이미지가 삭제됨
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
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
                                              '사진을 삭제하시겠습니까?',
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
                                                    images
                                                        .remove(images[index]);
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (images.isNotEmpty)
                      const SizedBox(
                        height: 50,
                      ),
                  ],
                ),
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
    );
  }
}
