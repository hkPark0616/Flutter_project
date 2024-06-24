import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ConvertTimestamp {
  static String returnDatetime(timestamp) {
    Timestamp time = timestamp;
    DateTime dateTime = time.toDate();
    String date = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    return date;
  }
}
