import 'package:json_annotation/json_annotation.dart';

part '../gen/models/message_model.gen.dart';

@JsonSerializable()
class MessageModel {
  final int timestamp;
  final List<int> chars;

  MessageModel({required this.timestamp, required this.chars});

  MessageModel.fromString({required this.timestamp, required String message}) : chars = message.codeUnits;

  @JsonKey(ignore: true)
  String get message => String.fromCharCodes(chars);

  factory MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
}