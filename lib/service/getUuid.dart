import 'package:uuid/uuid.dart';

class GetUuid {
  static String getuuid() {
    // Generate a v1 (time-based) id -> '6c84fb90-12c4-11e1-840d-7b25c5ee775a'
    // Generate a v4 (random) id -> '110ec58a-a0f2-4ac4-8393-c866d813b8d1'
    String uuid = const Uuid().v4();
    print(DateTime.now());
    return uuid;
  }
}
