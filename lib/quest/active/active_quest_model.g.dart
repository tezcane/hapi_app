// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_quest_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActiveQuestModel _$ActiveQuestModelFromJson(Map<String, dynamic> json) =>
    ActiveQuestModel(
      day: json['day'] as String,
      done: json['done'] as int,
      skip: json['skip'] as int,
      miss: json['miss'] as int,
    );

Map<String, dynamic> _$ActiveQuestModelToJson(ActiveQuestModel instance) =>
    <String, dynamic>{
      'day': instance.day,
      'done': instance.done,
      'skip': instance.skip,
      'miss': instance.miss,
    };
