import 'package:equatable/equatable.dart';

/// Session tag.
final class Tag extends Equatable {
  const Tag({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  List<Object?> get props => [
    id,
    name,
  ];
}
