import 'package:flutter/material.dart';

/// Formats unread count for badge labels; caps at `9+`.
String formatUnreadCount(int count) {
  if (count <= 0) {
    return '';
  }
  return count > 9 ? '9+' : '$count';
}

/// Material [Badge] wrapper; hidden when [count] is zero.
Widget unreadBadge({
  required int count,
  required Widget child,
}) {
  return Badge(
    isLabelVisible: count > 0,
    label: Text(formatUnreadCount(count)),
    child: child,
  );
}
