import 'package:flutter/material.dart';
import 'package:myapp/screens/boardScreen.dart';
import 'package:myapp/screens/loginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// auto login check,
// token O ==> BoardScreen,  token X ==> LoginScreen
class TokenCheck extends StatefulWidget {
  const TokenCheck({super.key});

  @override
  State<TokenCheck> createState() => _TokenCheckState();
}

class _TokenCheckState extends State<TokenCheck> {
  bool isToken = false;

  String? userEmail;
  String? createdDate;
  String? userId;

  @override
  void initState() {
    super.initState();
    _autoLoginCheck();
  }

  // 자동 로그인 설정 시, 공유 저장소에 토큰 저장
  void _autoLoginCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    userEmail = prefs.getString('userEmail');
    createdDate = prefs.getString('createdDate');
    userId = prefs.getString('userId');

    if (userEmail != null && createdDate != null && userId != null) {
      setState(() {
        isToken = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // 토큰이 있으면 메인 페이지, 없으면 로그인 페이지
      home: isToken
          ? BoardScreen(
              userEmail: userEmail,
              createdDate: createdDate,
              userId: userId,
            )
          : const LoginScreen(),
    );
  }
}
