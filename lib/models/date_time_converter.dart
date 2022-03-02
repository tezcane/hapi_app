import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Non-nullable version
class DateTimeConverter implements JsonConverter<DateTime, Timestamp> {
  const DateTimeConverter();

  @override
  DateTime fromJson(Timestamp json) =>
      DateTime.fromMicrosecondsSinceEpoch(json.millisecondsSinceEpoch);

  @override
  Timestamp toJson(DateTime object) =>
      Timestamp.fromMicrosecondsSinceEpoch(object.millisecondsSinceEpoch);
}

/// Nullable version
class DateTimeConverterN implements JsonConverter<DateTime?, Timestamp?> {
  const DateTimeConverterN();

  @override
  DateTime? fromJson(Timestamp? timestamp) {
    return timestamp?.toDate();
  }

  @override
  Timestamp? toJson(DateTime? date) =>
      date != null ? Timestamp.fromDate(date) : null;
}
