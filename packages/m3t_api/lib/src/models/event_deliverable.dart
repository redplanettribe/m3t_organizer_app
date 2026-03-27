import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_deliverable.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class EventDeliverable extends Equatable {
  const EventDeliverable({
    required this.id,
    required this.name,
    this.description,
  });

  factory EventDeliverable.fromJson(Map<String, dynamic> json) =>
      _$EventDeliverableFromJson(json);

  final String id;
  final String name;
  final String? description;

  Map<String, dynamic> toJson() => _$EventDeliverableToJson(this);

  @override
  List<Object?> get props => [id, name, description];
}
