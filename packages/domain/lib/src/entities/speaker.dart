import 'package:equatable/equatable.dart';

/// Session speaker.
final class Speaker extends Equatable {
  const Speaker({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.isTopSpeaker,
  });

  final String id;
  final String firstName;
  final String lastName;
  final bool isTopSpeaker;

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    isTopSpeaker,
  ];
}
