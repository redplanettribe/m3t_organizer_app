import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:m3t_api/src/models/event_registration.dart';
import 'package:m3t_api/src/models/pagination_meta.dart';

part 'event_registration_page.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class EventRegistrationPage extends Equatable {
  const EventRegistrationPage({
    required this.items,
    this.pagination,
  });

  factory EventRegistrationPage.fromJson(Map<String, dynamic> json) =>
      _$EventRegistrationPageFromJson(json);

  final List<EventRegistration> items;
  final PaginationMeta? pagination;

  EventRegistrationPage copyWith({
    List<EventRegistration>? items,
    Object? pagination = _sentinel,
  }) {
    return EventRegistrationPage(
      items: items ?? this.items,
      pagination: pagination == _sentinel
          ? this.pagination
          : pagination as PaginationMeta?,
    );
  }

  Map<String, dynamic> toJson() => _$EventRegistrationPageToJson(this);

  static const _sentinel = Object();

  @override
  List<Object?> get props => [items, pagination];
}
