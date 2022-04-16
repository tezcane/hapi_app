// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_quest_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActiveQuestModel _$ActiveQuestModelFromJson(Map<String, dynamic> json) =>
    ActiveQuestModel(
      day: const DateTimeConverter().fromJson(json['day'] as Timestamp),
      done: json['done'] as int,
      skip: json['skip'] as int,
      miss: json['miss'] as int,
    );

Map<String, dynamic> _$ActiveQuestModelToJson(ActiveQuestModel instance) =>
    <String, dynamic>{
      'day': const DateTimeConverter().toJson(instance.day),
      'done': instance.done,
      'skip': instance.skip,
      'miss': instance.miss,
    };
