import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

/// Foreground FCM delivery with optional OS notification fields.
final class ForegroundPushDelivery extends Equatable {
  const ForegroundPushDelivery({
    required this.message,
    this.title,
    this.body,
  });

  final PushNotificationMessage message;
  final String? title;
  final String? body;

  @override
  List<Object?> get props => [message, title, body];
}
