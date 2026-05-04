/// Builds `ws`/`wss` URL for `GET /ws?ticket=…` from REST [apiBaseUrl].
Uri organizerAgendaWebSocketUri({
  required String apiBaseUrl,
  required String ticket,
}) {
  final base = Uri.parse(apiBaseUrl);
  final wsScheme = base.scheme == 'https' ? 'wss' : 'ws';
  var basePath = base.path;
  if (basePath.endsWith('/')) {
    basePath = basePath.substring(0, basePath.length - 1);
  }
  final wsPath = basePath.isEmpty ? '/ws' : '$basePath/ws';
  return Uri(
    scheme: wsScheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
    path: wsPath,
    queryParameters: <String, String>{'ticket': ticket},
  );
}
