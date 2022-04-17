import 'package:json_annotation/json_annotation.dart';

part 'active_quest_model.g.dart';

/// Generate with:
///   flutter pub run build_runner build --delete-conflicting-outputs
@JsonSerializable()
class ActiveQuestModel {
  ActiveQuestModel({
    required this.day,
    required this.done,
    required this.skip,
    required this.miss,
  });

  String day;
  int done;
  int skip;
  int miss;

  factory ActiveQuestModel.fromJson(Map<String, dynamic> json) =>
      _$ActiveQuestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveQuestModelToJson(this);
}
