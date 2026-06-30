import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_organizer/features/chat/widgets/chat_message_bubble.dart';
import 'package:m3t_organizer/features/chat/widgets/reaction_bar.dart';

void main() {
  final message = ChatMessage(
    messageId: 'msg-1',
    eventId: 'evt-1',
    channelType: ChatChannelType.general,
    senderUserId: 'user-2',
    senderName: 'Alice',
    body: 'Hello world',
    createdAt: DateTime.utc(2026, 6, 8, 12),
    reactions: const [
      ChatReaction(emoji: '👍', count: 2, reactedByMe: true),
    ],
  );

  Widget buildBubble({
    required void Function(String emoji) onReact,
    VoidCallback? onReply,
    VoidCallback? onDelete,
    bool isOwn = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ChatMessageBubble(
            message: message,
            isOwn: isOwn,
            onReact: onReact,
            onReply: onReply ?? () {},
            onDelete: onDelete,
          ),
        ),
      ),
    );
  }

  group('ChatMessageBubble', () {
    testWidgets('renders message body and reaction pills', (tester) async {
      await tester.pumpWidget(buildBubble(onReact: (_) {}));

      expect(find.text('Hello world'), findsOneWidget);
      expect(find.text('👍'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('long-press shows reaction bar and actions menu', (
      tester,
    ) async {
      await tester.pumpWidget(buildBubble(onReact: (_) {}));
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Hello world'));
      await tester.pumpAndSettle();

      expect(find.byType(ReactionBar), findsOneWidget);
      expect(find.text('Reply'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('long-press reaction tap invokes onReact', (tester) async {
      String? reactedEmoji;
      await tester.pumpWidget(
        buildBubble(onReact: (emoji) => reactedEmoji = emoji),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Hello world'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('❤️'));
      await tester.pumpAndSettle();

      expect(reactedEmoji, '❤️');
    });

    testWidgets('long-press reply action invokes onReply', (tester) async {
      var replied = false;
      await tester.pumpWidget(
        buildBubble(
          onReact: (_) {},
          onReply: () => replied = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Hello world'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reply'));
      await tester.pumpAndSettle();

      expect(replied, isTrue);
    });

    testWidgets('delete action shown for own messages only', (tester) async {
      await tester.pumpWidget(
        buildBubble(
          onReact: (_) {},
          isOwn: true,
          onDelete: () {},
        ),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Hello world'));
      await tester.pumpAndSettle();

      expect(find.text('Delete'), findsOneWidget);
    });
  });
}
