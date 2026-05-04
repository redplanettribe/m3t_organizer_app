import 'package:equatable/equatable.dart';

/// Response body `data` from `POST /events/{id}/agenda/ws/ticket`.
final class AgendaWsTicket extends Equatable {
  const AgendaWsTicket({
    required this.ticket,
    required this.expiresAt,
  });

  factory AgendaWsTicket.fromJson(Map<String, dynamic> json) {
    return AgendaWsTicket(
      ticket: json['ticket'] as String,
      expiresAt: json['expires_at'] as String,
    );
  }

  final String ticket;
  final String expiresAt;

  @override
  List<Object?> get props => [ticket, expiresAt];
}
