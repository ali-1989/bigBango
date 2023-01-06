import 'package:app/structures/enums/supportSessionStatus.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

class SupportSessionModel {
  String id = '';
  String subject = '';
  SupportSessionStatus status = SupportSessionStatus.unKnow;
  int durationMinutes = 0;
  late DateTime reservationAt;
  LessonModel? lesson;

  SupportSessionModel.fromMap(Map map) {
    id = map['id'];
    subject = map['subject'];
    status = SupportSessionStatus.from(map['status']?? 1);
    durationMinutes = map['durationMinutes']?? 0;
    reservationAt = DateHelper.tsToSystemDate(map['reservationAt'])!;

    if(map['lesson'] is Map) {
      lesson = LessonModel.fromMap(map['lesson']);
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['id'] = id;
    map['subject'] = subject;
    map['status'] = status;
    map['durationMinutes'] = durationMinutes;
    map['reservationAt'] = DateHelper.toTimestamp(reservationAt);
    map['lesson'] = lesson?.toMap();

    return map;
  }
}