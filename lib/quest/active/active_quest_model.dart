import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hapi/models/date_time_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'active_quest_model.g.dart';

/// Generate with:
///   flutter pub run build_runner build --delete-conflicting-outputs
@JsonSerializable()
@DateTimeConverter()
class ActiveQuestModel {
  ActiveQuestModel({
    required this.day,
    required this.done,
    required this.skip,
    required this.miss,
  });

  DateTime day;
  int done;
  int skip;
  int miss;

  factory ActiveQuestModel.fromJson(Map<String, dynamic> json) =>
      _$ActiveQuestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveQuestModelToJson(this);
}
