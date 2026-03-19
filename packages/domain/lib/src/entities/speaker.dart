import 'package:equatable/equatable.dart';

/// Session speaker.
final class Speaker extends Equatable {
  const Speaker({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.isTopSpeaker,
    this.profilePicture,
    this.tagLine,
    this.bio,
  });

  final String id;
  final String firstName;
  final String lastName;
  final bool isTopSpeaker;
  final String? profilePicture;
  final String? tagLine;
  final String? bio;

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    isTopSpeaker,
    profilePicture,
    tagLine,
    bio,
  ];
}
