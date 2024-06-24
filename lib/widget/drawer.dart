import 'package:flutter/material.dart';
import 'package:myapp/screens/loginScreen.dart';
import 'package:myapp/widget/toastMessage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// logout
Future<void> logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // SharedPreferences에서 사용자 정보 삭제
  prefs.remove('userEmail');
  prefs.remove('createdDate');
  prefs.remove('userId');
}

class CustomDrawer extends StatelessWidget {
  final String userEmail;
  final String createdDate;
  final String userId;

  CustomDrawer({
    required this.userEmail,
    required this.createdDate,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.zero,
            margin: const EdgeInsets.only(bottom: 15),
            height: 270, // 원하는 높이로 조절
            decoration: const BoxDecoration(
              color: Color(0xFF9F7BFF),
              // borderRadius: BorderRadius.only(
              //   bottomRight: Radius.circular(15.0),
              // ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    child: const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                      radius: 60.0,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30.0),
                    child: Text(
                      userEmail,
                      style: const TextStyle(
                          fontSize: 29.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Dongle',
                          height: 0.5),
                    ),
                  ),
                  SizedBox(
                    child: Text(
                      createdDate,
                      style: const TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontFamily: 'Dongle',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.only(left: 10),
            child: ListTile(
              leading: Icon(
                Icons.account_circle_outlined,
                color: Colors.grey[850],
                size: 23,
              ),
              title: const Text(
                'My Info',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Dongle',
                ),
              ),
              onTap: () {
                print("home is clicked");
              },
              // trailing: Icon(Icons.add),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 10),
            child: ListTile(
              leading: Icon(
                Icons.list_alt_rounded,
                color: Colors.grey[850],
                size: 23,
              ),
              title: const Text(
                'My Post',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Dongle',
                ),
              ),
              onTap: () {
                print("settings is clicked");
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.only(left: 10),
            child: ListTile(
              leading: Icon(
                Icons.question_answer,
                color: Colors.grey[850],
                size: 23,
              ),
              title: const Text(
                'question_answer',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Dongle',
                ),
              ),
              onTap: () {
                print("question_answer is clicked");
              },
            ),
          ),

          // Drawer space
          const Expanded(
              child: Center(
            child: null,
          )),

          // Drawer footer
          Container(
            padding: const EdgeInsets.all(3.0),
            color: const Color(0xFF9F7BFF),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9F7BFF),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
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
                              backgroundColor: Colors.white,
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '로그아웃 하시겠습니까?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 25,
                                      fontFamily: 'Dongle',
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    '취소',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      fontFamily: 'Dongle',
                                    ),
                                  ),
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
                                    Navigator.of(context).pop();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                    ToastWidget.showToast('로그아웃 되었습니다.');
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.logout_outlined,
                        color: Colors.white,
                        size: 28.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
