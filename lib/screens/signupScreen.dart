import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:myapp/widget/toastMessage.dart';
import 'package:myapp/screens/loginScreen.dart';
import 'package:myapp/service/auth.dart';
import 'package:myapp/service/hash.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => SignupState();
}

class SignupState extends State<SignupScreen> {
  // 유저의 아이디와 비밀번호의 정보 저장
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordVerifyingController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final int idLength = 8;
  final int passwordLength = 10;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            // image: DecorationImage(
            //   image: AssetImage("assets/images/back_1.jpg"),
            //   fit: BoxFit.cover,
            // ),
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Color.fromARGB(255, 125, 82, 199),
                Color.fromARGB(214, 255, 255, 255)
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
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
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Column(
                                //crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sign up',
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
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
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
                                    labelText: 'Create Email',
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
                                        color:
                                            Color.fromARGB(255, 255, 123, 123),
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color:
                                            Color.fromARGB(255, 255, 123, 123),
                                      ),
                                    ),
                                    errorStyle: TextStyle(
                                      fontFamily: 'Dongle',
                                      fontSize: 20,
                                      height: 0.5,
                                    ),
                                  ),
                                  //onSaved: (email) => _userEmail = email as String,
                                  onChanged: (value) async {
                                    // _formKey.currentState!.validate();
                                    // _formKey.currentState!.save();

                                    // bool result =
                                    //     await confirmIdCheck(userIdController.text);
                                    // setState(() {
                                    //   isIdValid = result;
                                    // });
                                  },
                                  validator: (value) {
                                    // id 유효성 검사
                                    if (value!.isEmpty) {
                                      return 'Please enter your email';
                                    } else if (value.length < idLength) {
                                      return 'Email must be at least $idLength characters';
                                    } else if (!RegExp(
                                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                                        .hasMatch(value)) {
                                      return 'Invalid email format';
                                    }
                                    // } else if (isIdValid) {
                                    //   return 'Exist email';
                                    // }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          // 비밀번호 입력 텍스트필드
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              textInputAction: TextInputAction.next,
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
                                labelText: 'Create Password',
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
                              onChanged: (value) {},
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                } else if (value.length < passwordLength) {
                                  return 'Password must be at least $passwordLength characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 14,
                          ),

                          // 비밀번호 재확인 텍스트필드
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: passwordVerifyingController,
                              textAlign: TextAlign.center,
                              obscureText: true,
                              style: const TextStyle(
                                color: Color(0xFF393939),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Confirm Password',
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
                              onChanged: (value) {},
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                } else if (value != passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),

                          // 로그인 페이지로 돌아가기
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 55,
                                  height: 50,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor: const Color(0xFF9F7BFF),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    // child: const Icon(
                                    //   Icons.arrow_back,
                                    //   color: Colors.white,
                                    //   size: 25,
                                    // ),
                                  ),
                                ),
                                const SizedBox(width: 5),

                                // 계정 생성 버튼
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width - 140,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        _formKey.currentState!.save();
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();

                                        try {
                                          // user email duplicate check
                                          bool emailCheck =
                                              await emailDuplicateCheck(
                                                  userIdController.text);

                                          if (emailCheck) {
                                            // can use email, do register
                                            if (!mounted) return;
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
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
                                                      textAlign:
                                                          TextAlign.center,
                                                      '알림',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 27,
                                                        fontFamily: 'Dongle',
                                                      ),
                                                    ),
                                                  ),
                                                  content: const Text(
                                                    '회원가입 하시겠습니까?',
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
                                                        Navigator.of(context)
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
                                                        Navigator.of(context)
                                                            .pop();
                                                        //get Token
                                                        String? getToken;
                                                        await FirebaseMessaging
                                                            .instance
                                                            .getToken()
                                                            .then((token) {
                                                          getToken = token;
                                                        });

                                                        // get userId
                                                        var now = DateTime.now()
                                                            .toString();
                                                        String userId =
                                                            now.replaceAll(
                                                                RegExp('\\D'),
                                                                "");

                                                        // hashed password
                                                        final hashPw =
                                                            await bcryptPassword(
                                                                passwordController
                                                                    .text);
                                                        DateTime datetime =
                                                            DateTime.now();
                                                        // register user data
                                                        var registerUserData = {
                                                          "email":
                                                              userIdController
                                                                  .text,
                                                          "password": hashPw,
                                                          "token": getToken,
                                                          "tokenExpirationPeriod":
                                                              DateTime.now()
                                                                  .millisecondsSinceEpoch,
                                                          "userId": userId,
                                                          "createdDate": DateFormat(
                                                                  'yyyy-MM-dd HH:mm:ss')
                                                              .format(datetime),
                                                        };

                                                        // do register
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(
                                                                userIdController
                                                                    .text)
                                                            .set(
                                                                registerUserData);

                                                        // register success toast message
                                                        ToastWidget.showToast(
                                                            '회원가입이 완료되었습니다!');

                                                        // go to login screen
                                                        if (context.mounted) {
                                                          Navigator.pop(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const SignupScreen(),
                                                            ),
                                                          );
                                                          Navigator
                                                              .pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const LoginScreen(),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else {
                                            // already exist email
                                            if (!mounted) return;
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
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
                                                      textAlign:
                                                          TextAlign.center,
                                                      '알림',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 27,
                                                        fontFamily: 'Dongle',
                                                      ),
                                                    ),
                                                  ),
                                                  content: const Text(
                                                    '이미 존재하는 아이디입니다.',
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
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 24,
                                                          fontFamily: 'Dongle',
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        } catch (e) {
                                          print(e);
                                          ToastWidget.showToast(
                                              '알 수 없는 오류가 발생했습니다. 잠시 후에 다시 시도해주세요.');
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF9F7BFF),
                                    ),
                                    child: const Text(
                                      'Create Account',
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
                              ],
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
    );
  }
}
