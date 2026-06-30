import 'dart:async';
import 'dart:convert';

import 'package:m3t_api/src/m3t_api_client.dart';
import 'package:m3t_api/src/realtime/ws_frame.dart';
import 'package:m3t_api/src/realtime/ws_uri.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const _pingInterval = Duration(seconds: 30);
const _initialReconnectDelay = Duration(seconds: 1);
const _maxReconnectDelay = Duration(seconds: 30);

/// Shared multiplexed `GET /ws` connection with bearer auth.
final class WsMultiplexer {
  WsMultiplexer({
    required String apiBaseUrl,
    required TokenProvider tokenProvider,
  }) : _apiBaseUrl = apiBaseUrl,
       _tokenProvider = tokenProvider;

  final String _apiBaseUrl;
  final TokenProvider _tokenProvider;

  bool _disposed = false;
  bool _connectRequested = false;
  bool _loopRunning = false;
  WebSocketChannel? _channel;
  Timer? _pingTimer;
  StreamSubscription<dynamic>? _messageSubscription;
  final Map<String, int> _topicRefCounts = {};
  final Map<String, StreamController<WsFrame>> _topicStreams = {};
  Duration _reconnectDelay = _initialReconnectDelay;

  /// Starts (or keeps) the reconnect loop for the app session.
  void connect() {
    if (_disposed) return;
    _connectRequested = true;
    if (_loopRunning) return;
    _loopRunning = true;
    unawaited(_runLoop());
  }

  /// Increments ref-count for [topic] and sends `subscribe` on first holder.
  void subscribe(String topic) {
    if (_disposed) return;
    final count = (_topicRefCounts[topic] ?? 0) + 1;
    _topicRefCounts[topic] = count;
    _ensureTopicStream(topic);
    connect();
    if (count == 1) {
      _sendSubscribe(topic);
    }
  }

  /// Decrements ref-count; sends `unsubscribe` when last holder releases.
  void unsubscribe(String topic) {
    final count = (_topicRefCounts[topic] ?? 0) - 1;
    if (count <= 0) {
      _topicRefCounts.remove(topic);
      _sendUnsubscribe(topic);
    } else {
      _topicRefCounts[topic] = count;
    }
  }

  /// Server push frames routed to [topic].
  Stream<WsFrame> frames(String topic) {
    _ensureTopicStream(topic);
    return _topicStreams[topic]!.stream;
  }

  /// Tears down the socket, timers, and topic streams.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _connectRequested = false;
    _loopRunning = false;
    _pingTimer?.cancel();
    _pingTimer = null;
    unawaited(_messageSubscription?.cancel());
    _messageSubscription = null;
    unawaited(_channel?.sink.close());
    _channel = null;
    for (final controller in _topicStreams.values) {
      unawaited(controller.close());
    }
    _topicStreams.clear();
    _topicRefCounts.clear();
  }

  void _ensureTopicStream(String topic) {
    _topicStreams.putIfAbsent(
      topic,
      StreamController<WsFrame>.broadcast,
    );
  }

  Future<void> _runLoop() async {
    while (!_disposed && _connectRequested) {
      try {
        final token = await _tokenProvider();
        if (_disposed || !_connectRequested) return;

        final uri = bearerWebSocketUri(apiBaseUrl: _apiBaseUrl);
        final headers = <String, dynamic>{};
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }

        final channel = IOWebSocketChannel.connect(uri, headers: headers);
        _channel = channel;
        _reconnectDelay = _initialReconnectDelay;
        _startPing();
        _resubscribeAll();

        await for (final message in channel.stream) {
          if (_disposed) break;
          _handleRawMessage(message);
        }
      } on Object catch (_) {
        // Reconnect loop handles transient failures.
      } finally {
        _pingTimer?.cancel();
        _pingTimer = null;
        await _messageSubscription?.cancel();
        _messageSubscription = null;
        await _channel?.sink.close();
        _channel = null;
      }

      if (_disposed || !_connectRequested) return;

      await Future<void>.delayed(_reconnectDelay);
      final nextMs = (_reconnectDelay.inMilliseconds * 2).clamp(
        _initialReconnectDelay.inMilliseconds,
        _maxReconnectDelay.inMilliseconds,
      );
      _reconnectDelay = Duration(milliseconds: nextMs);
    }
    _loopRunning = false;
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      _sendFrame(<String, dynamic>{
        'type': 'ping',
        'id': 'ping-${DateTime.now().microsecondsSinceEpoch}',
      });
    });
  }

  void _resubscribeAll() {
    _topicRefCounts.keys.forEach(_sendSubscribe);
  }

  void _sendSubscribe(String topic) {
    _sendFrame(<String, dynamic>{
      'type': 'subscribe',
      'topic': topic,
      'id': 'sub-${DateTime.now().microsecondsSinceEpoch}',
    });
  }

  void _sendUnsubscribe(String topic) {
    _sendFrame(<String, dynamic>{
      'type': 'unsubscribe',
      'topic': topic,
      'id': 'unsub-${DateTime.now().microsecondsSinceEpoch}',
    });
  }

  void _sendFrame(Map<String, dynamic> frame) {
    final channel = _channel;
    if (channel == null) return;
    channel.sink.add(jsonEncode(frame));
  }

  void _handleRawMessage(dynamic message) {
    final text = switch (message) {
      final String s => s,
      final List<int> bytes => utf8.decode(bytes),
      _ => message.toString(),
    };

    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) return;

      final type = decoded['type'] as String?;
      if (type == 'pong') return;

      if (type == 'error') {
        _surfaceErrorFrame(decoded);
        return;
      }

      final frame = WsFrame.fromJson(decoded);
      if (frame.topic.isEmpty) return;

      final controller = _topicStreams[frame.topic];
      if (controller != null && !controller.isClosed) {
        controller.add(frame);
      }
    } on Object {
      // Ignore malformed frames.
    }
  }

  void _surfaceErrorFrame(Map<String, dynamic> decoded) {
    final data = decoded['data'];
    final error = data is Map<String, dynamic>
        ? StateError('${data['code']}: ${data['message']}')
        : StateError('websocket error frame');

    for (final controller in _topicStreams.values) {
      if (!controller.isClosed) {
        controller.addError(error);
      }
    }
  }
}
