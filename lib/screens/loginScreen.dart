import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/boardScreen.dart';
import 'package:myapp/screens/signupScreen.dart';
import 'package:myapp/service/auth.dart';
import 'package:myapp/service/popScope.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  // 자동 로그인 여부
  bool switchValue = false;

  // 아이디와 비밀번호 정보
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // 자동 로그인
  Future<void> _setAutoLogin(Map<String, dynamic> userData) async {
    // 공유저장소에 유저의 email(id), createdDate, userId 저장
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('userEmail', userData['userEmail']);
    prefs.setString('createdDate', userData['createdDate']);
    prefs.setString('userId', userData['userId']);
  }

  // 자동 로그인 해제
  void _delAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
    await prefs.remove('createdDate');
    await prefs.remove('userId');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PopScope(
        canPop: true,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          goBack();
        },
        child: Scaffold(
          //resizeToAvoidBottomInset: false,
          body: Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              // image: DecorationImage(
              //   image: AssetImage("assets/images/back_1.jpg"),
              //   fit: BoxFit.cover,
              // ),
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  // Color.fromARGB(255, 186, 128, 196),
                  Color.fromARGB(255, 125, 82, 199),
                  Color.fromARGB(214, 255, 255, 255)
                ],
              ),
              // color: Color.fromARGB(255, 238, 227, 240)
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(214, 255, 255, 255),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Column(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Log in',
                                      style: TextStyle(
                                        color: Color(0xFF755DC1),
                                        fontSize: 45,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Dongle',
                                        height: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),

                            // ID 입력 텍스트필드
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextFormField(
                                textInputAction: TextInputAction.next,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller: userIdController,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF393939),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Enter your Email',
                                  labelStyle: TextStyle(
                                    color: Color(0xFF755DC1),
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Dongle',
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Color(0xFF837E93),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Color(0xFF9F7BFF),
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Color.fromARGB(255, 255, 123, 123),
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Color.fromARGB(255, 255, 123, 123),
                                    ),
                                  ),
                                  errorStyle: TextStyle(
                                    fontFamily: 'Dongle',
                                    fontSize: 20,
                                    height: 0.5,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),

                            // 비밀번호 입력 텍스트필드
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller: passwordController,
                                textAlign: TextAlign.center,
                                obscureText: true,
                                style: const TextStyle(
                                  color: Color(0xFF393939),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Enter your Password',
                                  labelStyle: TextStyle(
                                      color: Color(0xFF755DC1),
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Dongle'),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Color(0xFF837E93),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Color(0xFF9F7BFF),
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Color.fromARGB(255, 255, 123, 123),
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Color.fromARGB(255, 255, 123, 123),
                                    ),
                                  ),
                                  errorStyle: TextStyle(
                                    fontFamily: 'Dongle',
                                    fontSize: 20,
                                    height: 0.5,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),

                            // 자동 로그인 확인 토글 스위치
                            SizedBox(
                              width: 300,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '자동 로그인 ',
                                    style: TextStyle(
                                      color: Color(0xFF9F7BFF),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 23,
                                      fontFamily: 'Dongle',
                                      height: 0.5,
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    // 부울 값으로 스위치 토글 (value)
                                    value: switchValue,
                                    activeColor: const Color(0xFF9F7BFF),
                                    onChanged: (bool? value) {
                                      // 스위치가 토글될 때 실행될 코드
                                      setState(() {
                                        switchValue = value ?? false;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 20),

                                  // 계정 생성 페이지로 이동하는 버튼
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          width: 1.0, color: Color(0xFF9F7BFF)),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SignupScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Sign up',
                                      style: TextStyle(
                                        color: Color(0xFF9F7BFF),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 23,
                                        fontFamily: 'Dongle',
                                        height: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),

                            // 로그인 버튼
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 20),
                              child: SizedBox(
                                width: 335,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // user account check & get login user data
                                    final Map<String, dynamic> userData =
                                        await login(userIdController.text,
                                            passwordController.text);

                                    if (!mounted) return;
                                    // id & pw is confirmed
                                    if (_formKey.currentState!.validate() &&
                                        userData['userId'] != null) {
                                      _formKey.currentState!.save();
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
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
                                              '로그인 되었습니다.',
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
                                                  '확인',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                    fontFamily: 'Dongle',
                                                  ),
                                                ),
                                                onPressed: () {
                                                  // 자동 로그인 확인
                                                  if (switchValue == true) {
                                                    _setAutoLogin(userData);
                                                  } else {
                                                    _delAutoLogin();
                                                  }

                                                  Navigator.of(context).pop();
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) {
                                                        return BoardScreen(
                                                          userEmail: userData[
                                                              'userEmail'],
                                                          createdDate: userData[
                                                              'createdDate'],
                                                          userId: userData[
                                                              'userId'],
                                                        );
                                                      },
                                                      // const MainPage(),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
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
                                              '아이디 및 비밀번호를 확인해주세요.',
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
                                                  '확인',
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
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF9F7BFF),
                                  ),
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 27,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Dongle',
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
