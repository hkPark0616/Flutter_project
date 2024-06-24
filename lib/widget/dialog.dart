import 'package:flutter/material.dart';

deleteCommentsDialog(BuildContext context, String commentId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
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
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
