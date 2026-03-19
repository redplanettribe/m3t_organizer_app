import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'speaker.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class Speaker extends Equatable {
  const Speaker({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.isTopSpeaker,
    this.bio,
    this.eventId,
    this.profilePicture,
    this.source,
    this.sourceSessionId,
    this.tagLine,
    this.createdAt,
    this.updatedAt,
  });

  factory Speaker.fromJson(Map<String, dynamic> json) =>
      _$SpeakerFromJson(json);

  final String id;
  final String firstName;
  final String lastName;
  final bool isTopSpeaker;

  final String? bio;
  final String? eventId;
  final String? profilePicture;
  final String? source;
  final String? sourceSessionId;
  final String? tagLine;
  final String? createdAt;
  final String? updatedAt;

  Map<String, dynamic> toJson() => _$SpeakerToJson(this);

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    isTopSpeaker,
    bio,
    eventId,
    profilePicture,
    source,
    sourceSessionId,
    tagLine,
    createdAt,
    updatedAt,
  ];
}
