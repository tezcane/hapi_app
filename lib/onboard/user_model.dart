import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// User Model contains the model for our user saved in firestore.
/// NOTE: Don't modify this as it is closely tied to firestore libraries.
@JsonSerializable()
class UserModel {
  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.photoUrl,
  });

  final String uid;
  final String email;
  final String name;
  final String photoUrl;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
