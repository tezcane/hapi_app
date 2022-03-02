// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'do_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoListModel _$DoListModelFromJson(Map<String, dynamic> json) => DoListModel(
      id: json['id'] as String,
      content: json['content'] as String,
      dateCreated:
          const DateTimeConverter().fromJson(json['dateCreated'] as Timestamp),
      dateStart:
          const DateTimeConverterN().fromJson(json['dateStart'] as Timestamp?),
      dateEnd:
          const DateTimeConverterN().fromJson(json['dateEnd'] as Timestamp?),
      dateDone:
          const DateTimeConverterN().fromJson(json['dateDone'] as Timestamp?),
      done: json['done'] as bool,
    );

Map<String, dynamic> _$DoListModelToJson(DoListModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'dateCreated': const DateTimeConverter().toJson(instance.dateCreated),
      'dateStart': const DateTimeConverterN().toJson(instance.dateStart),
      'dateEnd': const DateTimeConverterN().toJson(instance.dateEnd),
      'dateDone': const DateTimeConverterN().toJson(instance.dateDone),
      'done': instance.done,
    };
