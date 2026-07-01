/// Domain failures for device push-token operations.
sealed class DeviceTokenFailure implements Exception {}

final class DeviceTokenNetworkError extends DeviceTokenFailure {}

final class DeviceTokenUnauthorized extends DeviceTokenFailure {}

final class DeviceTokenInvalidInput extends DeviceTokenFailure {}

final class DeviceTokenUserNotFound extends DeviceTokenFailure {}

final class DeviceTokenUnknownError extends DeviceTokenFailure {}
