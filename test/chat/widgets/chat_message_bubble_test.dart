import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_organizer/features/chat/widgets/chat_message_bubble.dart';
import 'package:m3t_organizer/features/chat/widgets/chat_message_grouping.dart';
import 'package:m3t_organizer/features/chat/widgets/chat_sender_avatar.dart';
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
    VoidCallback? onSenderTap,
    bool isOwn = false,
    bool showSenderHeader = true,
    ChatMessage? messageOverride,
    Size viewportSize = const Size(400, 920),
    Alignment alignment = Alignment.topCenter,
    double topPadding = 72,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: viewportSize.width,
          height: viewportSize.height,
          child: Align(
            alignment: alignment,
            child: Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: ChatMessageBubble(
              message: messageOverride ?? message,
              isOwn: isOwn,
              showSenderHeader: showSenderHeader,
              onReact: onReact,
              onReply: onReply ?? () {},
              onDelete: onDelete,
              onSenderTap: onSenderTap,
            ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pumpBubble(
    WidgetTester tester, {
    required Widget widget,
    Size viewportSize = const Size(400, 920),
  }) async {
    tester.view.physicalSize = viewportSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  group('showSenderHeaderForMessage', () {
    test('returns true when no previous message', () {
      expect(
        showSenderHeaderForMessage(
          message: message,
          chronologicallyPreviousMessage: null,
        ),
        isTrue,
      );
    });

    test('returns false for consecutive same-sender messages', () {
      final previous = ChatMessage(
        messageId: 'msg-0',
        eventId: 'evt-1',
        channelType: ChatChannelType.general,
        senderUserId: 'user-2',
        body: 'Earlier',
        createdAt: DateTime.utc(2026, 6, 8, 11),
      );
      expect(
        showSenderHeaderForMessage(
          message: message,
          chronologicallyPreviousMessage: previous,
        ),
        isFalse,
      );
    });

    test('returns true when sender changes', () {
      final previous = ChatMessage(
        messageId: 'msg-0',
        eventId: 'evt-1',
        channelType: ChatChannelType.general,
        senderUserId: 'user-3',
        body: 'Earlier',
        createdAt: DateTime.utc(2026, 6, 8, 11),
      );
      expect(
        showSenderHeaderForMessage(
          message: message,
          chronologicallyPreviousMessage: previous,
        ),
        isTrue,
      );
    });
  });

  group('ChatMessageBubble', () {
    testWidgets('renders message body and reaction pills', (tester) async {
      await pumpBubble(tester, widget: buildBubble(onReact: (_) {}));

      expect(find.text('Hello world'), findsOneWidget);
      expect(find.text('👍'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('short message bubble is narrower than max width', (
      tester,
    ) async {
      await pumpBubble(tester, widget: buildBubble(onReact: (_) {}));

      final bubbleBox = tester.renderObject<RenderBox>(
        find.ancestor(
          of: find.text('Hello world'),
          matching: find.byType(Container),
        ).first,
      );
      expect(bubbleBox.size.width, lessThan(400 * 0.78));
    });

    testWidgets('reply message does not expand to max width for short quote', (
      tester,
    ) async {
      final replyMessage = ChatMessage(
        messageId: 'msg-2',
        eventId: 'evt-1',
        channelType: ChatChannelType.general,
        senderUserId: 'user-2',
        senderName: 'Alice',
        body: 'Hello world',
        createdAt: DateTime.utc(2026, 6, 8, 12),
        replyTo: const ChatReplyTo(
          messageId: 'msg-0',
          senderUserId: 'user-3',
          senderName: 'Bob',
          body: 'Hi',
        ),
      );

      await pumpBubble(
        tester,
        widget: buildBubble(
          onReact: (_) {},
          messageOverride: replyMessage,
        ),
      );

      final bubbleBox = tester.renderObject<RenderBox>(
        find.ancestor(
          of: find.text('Hello world'),
          matching: find.byType(Container),
        ).first,
      );
      expect(bubbleBox.size.width, lessThan(400 * 0.78));
    });

    testWidgets('showSenderHeader shows avatar and sender name', (
      tester,
    ) async {
      await pumpBubble(
        tester,
        widget: buildBubble(onReact: (_) {}),
      );

      expect(find.byType(ChatSenderAvatar), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('showSenderHeader false hides avatar and name', (
      tester,
    ) async {
      await pumpBubble(
        tester,
        widget: buildBubble(onReact: (_) {}, showSenderHeader: false),
      );

      expect(find.byType(ChatSenderAvatar), findsNothing);
      expect(find.text('Alice'), findsNothing);
    });

    testWidgets('onSenderTap fires when sender name is tapped', (
      tester,
    ) async {
      var tapped = false;
      await pumpBubble(
        tester,
        widget: buildBubble(
          onReact: (_) {},
          onSenderTap: () => tapped = true,
        ),
      );

      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('onSenderTap fires when sender avatar is tapped', (
      tester,
    ) async {
      var tapped = false;
      await pumpBubble(
        tester,
        widget: buildBubble(
          onReact: (_) {},
          onSenderTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byType(ChatSenderAvatar));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('long-press shows reaction bar and actions menu', (
      tester,
    ) async {
      await pumpBubble(tester, widget: buildBubble(onReact: (_) {}));

      await tester.longPress(find.text('Hello world'));
      await tester.pumpAndSettle();

      expect(find.byType(ReactionBar), findsOneWidget);
      expect(find.text('Reply'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('long-press reaction tap invokes onReact', (tester) async {
      String? reactedEmoji;
      await pumpBubble(
        tester,
        widget: buildBubble(onReact: (emoji) => reactedEmoji = emoji),
      );

      await tester.longPress(find.text('Hello world'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('❤️'));
      await tester.pumpAndSettle();

      expect(reactedEmoji, '❤️');
    });

    testWidgets('long-press reply action invokes onReply', (tester) async {
      var replied = false;
      await pumpBubble(
        tester,
        widget: buildBubble(
          onReact: (_) {},
          onReply: () => replied = true,
        ),
      );

      await tester.longPress(find.text('Hello world'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reply'));
      await tester.pumpAndSettle();

      expect(replied, isTrue);
    });

    testWidgets('delete action shown for own messages only', (tester) async {
      await pumpBubble(
        tester,
        widget: buildBubble(
          onReact: (_) {},
          isOwn: true,
          onDelete: () {},
        ),
      );

      await tester.longPress(find.text('Hello world'));
      await tester.pumpAndSettle();

      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('long-press near bottom keeps reply menu below bubble', (
      tester,
    ) async {
      await pumpBubble(
        tester,
        viewportSize: const Size(400, 220),
        widget: buildBubble(
          onReact: (_) {},
          viewportSize: const Size(400, 220),
          alignment: Alignment.bottomCenter,
          topPadding: 0,
        ),
      );

      await tester.longPress(find.text('Hello world'));
      await tester.pumpAndSettle();

      expect(find.text('Reply'), findsOneWidget);

      final replyTop =
          tester.getTopLeft(find.text('Reply')).dy;
      final overlayBubbleBottom = tester
          .getBottomLeft(find.text('Hello world').last)
          .dy;

      expect(replyTop, greaterThan(overlayBubbleBottom));
    });
  });
}
