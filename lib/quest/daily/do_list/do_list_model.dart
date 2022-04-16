import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hapi/models/date_time_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'do_list_model.g.dart';

/// Generate with:
///   flutter pub run build_runner build --delete-conflicting-outputs
@JsonSerializable()
@DateTimeConverter()
@DateTimeConverterN()
class DoListModel {
  String id;
  String content;
  DateTime dateCreated;
  DateTime? dateStart;
  DateTime? dateEnd;
  DateTime? dateDone;
  bool done;

  DoListModel({
    required this.id,
    required this.content,
    required this.dateCreated,
    required this.dateStart,
    required this.dateEnd,
    required this.dateDone,
    required this.done,
  });

  factory DoListModel.fromJson(Map<String, dynamic> json) =>
      _$DoListModelFromJson(json);

  Map<String, dynamic> toJson() => _$DoListModelToJson(this);
}
