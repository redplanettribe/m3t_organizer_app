/// Chat channel kinds exposed by the event chat API.
enum ChatChannelType {
  general,
  dm,
  organizers,
}

/// Maps API `channel_type` strings to [ChatChannelType].
ChatChannelType chatChannelTypeFromApiValue(String raw) {
  return switch (raw.toLowerCase()) {
    'general' => ChatChannelType.general,
    'dm' => ChatChannelType.dm,
    'organizers' => ChatChannelType.organizers,
    _ => throw FormatException('Unknown chat channel_type: $raw'),
  };
}

/// Maps [ChatChannelType] to API `channel_type` strings.
String chatChannelTypeToApiValue(ChatChannelType type) {
  return switch (type) {
    ChatChannelType.general => 'general',
    ChatChannelType.dm => 'dm',
    ChatChannelType.organizers => 'organizers',
  };
}
