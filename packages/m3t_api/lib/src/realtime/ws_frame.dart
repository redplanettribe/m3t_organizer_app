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

  factory WsFrame.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return WsFrame(
      type: json['type'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      data: data is Map<String, dynamic> ? data : null,
      id: json['id'] as String?,
      ts: json['ts'] as String?,
    );
  }

  final String type;
  final String topic;
  final Map<String, dynamic>? data;
  final String? id;
  final String? ts;

  @override
  List<Object?> get props => [type, topic, data, id, ts];
}
