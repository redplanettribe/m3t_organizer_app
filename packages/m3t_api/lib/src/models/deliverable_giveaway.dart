import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:m3t_api/src/models/user.dart';

part 'deliverable_giveaway.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class DeliverableGiveaway extends Equatable {
  const DeliverableGiveaway({
    required this.id,
    required this.eventId,
    required this.deliverableId,
    required this.userId,
    required this.givenBy,
    required this.createdAt,
    this.name,
    this.lastName,
    this.email,
    this.deliverableName,
    this.user,
  });

  factory DeliverableGiveaway.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    if (normalized['created_at'] == null &&
        normalized['given_at'] != null) {
      normalized['created_at'] = normalized['given_at'];
    }
    return _$DeliverableGiveawayFromJson(normalized);
  }

  final String id;
  final String eventId;
  final String deliverableId;
  final String userId;
  final String givenBy;
  final String? name;
  final String? lastName;
  final String? email;
  final String? deliverableName;
  final String createdAt;
  final User? user;

  Map<String, dynamic> toJson() => _$DeliverableGiveawayToJson(this);

  @override
  List<Object?> get props => [
    id,
    eventId,
    deliverableId,
    userId,
    givenBy,
    name,
    lastName,
    email,
    deliverableName,
    createdAt,
    user,
  ];
}
