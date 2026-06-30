import 'package:equatable/equatable.dart';

/// Multiplexed WebSocket envelope: `{type, topic, data, id, ts}`.
final class WsFrame extends Equatable {
  const WsFrame({
    required this.type,
    required this.topic,
    this.data,
    this.id,
    this.ts,
  });

  factory WsFrame.fromEnvelope(Map<String, dynamic> envelope) {
    return WsFrame(
      type: envelope['type'] as String? ?? '',
      topic: envelope['topic'] as String? ?? '',
      data: envelope['data'],
      id: envelope['id'] as String?,
      ts: envelope['ts'] as String?,
    );
  }

  final String type;
  final String topic;
  final Object? data;
  final String? id;
  final String? ts;

  Map<String, dynamic>? get dataMap =>
      data is Map<String, dynamic> ? data! as Map<String, dynamic> : null;

  @override
  List<Object?> get props => [type, topic, data, id, ts];
}
