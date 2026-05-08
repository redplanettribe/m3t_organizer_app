/// Domain failures for remote-config operations.
sealed class GetMobileRemoteConfigFailure implements Exception {}

final class GetMobileRemoteConfigNetworkError
    extends GetMobileRemoteConfigFailure {}

final class GetMobileRemoteConfigInvalidInput
    extends GetMobileRemoteConfigFailure {}

final class GetMobileRemoteConfigUnknownError
    extends GetMobileRemoteConfigFailure {}
