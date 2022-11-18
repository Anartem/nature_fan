import 'package:json_annotation/json_annotation.dart';

part '../gen/models/anchor_model.gen.dart';

@JsonSerializable()
class AnchorModel {
  final List<double> position;

  AnchorModel({required this.position});

  factory AnchorModel.fromJson(Map<String, dynamic> json) => _$AnchorModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnchorModelToJson(this);
}