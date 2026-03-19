import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class Tag extends Equatable {
  const Tag({
    required this.id,
    required this.name,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  final String id;
  final String name;

  Map<String, dynamic> toJson() => _$TagToJson(this);

  @override
  List<Object?> get props => [id, name];
}
