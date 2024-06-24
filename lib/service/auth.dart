import 'dart:async';
import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/widget/toastMessage.dart';

// signup duplicated check
Future<bool> emailDuplicateCheck(String email) async {
  // duplicated email exist check to cloud firestore database
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: email)
      .get();
  if (querySnapshot.docs.isNotEmpty) {
    // already exist email
    return false;
  } else {
    // can use email
    return true;
  }
}

// login user check & return login user date
Future<Map<String, dynamic>> login(String email, String password) async {
  // user data
  Map<String, dynamic> userData = {};

  try {
    // id check to cloud firestore database
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    // Check if querySnapshot is empty
    if (querySnapshot.docs.isEmpty) {
      return userData; // No matching user found
    }

    // password check to cloud firestore database
    final String getPw = querySnapshot.docs[0]['password'];

    // Check if getpw returns null
    if (getPw == null) {
      return userData; // Password check failed
    }

    // check password
    final bool checkPassword = BCrypt.checkpw(password, getPw);

    // id & pw is confirmed
    if (querySnapshot.docs.isNotEmpty && checkPassword) {
      userData = {
        'userEmail': querySnapshot.docs[0]['email'],
        'createdDate': querySnapshot.docs[0]['createdDate'],
        'userId': querySnapshot.docs[0]['userId'],
      };

      return userData;
    }
    // id & pw is not confirmed
    else {
      return userData;
    }
  } catch (e) {
    ToastWidget.showToast('알 수 없는 오류가 발생했습니다. 잠시 후에 다시 시도해주세요.');
    return userData;
  }
}
