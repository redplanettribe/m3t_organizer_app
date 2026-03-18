import 'package:flutter/material.dart';
import 'package:m3t_organizer/features/my_events/my_events.dart';
import 'package:m3t_organizer/features/user/view/user_avatar_button.dart';

final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: UserAvatarButton(),
        ),
        title: const Text('m3t Organizer'),
      ),
      body: const SafeArea(
        child: MyEventsList(),
      ),
    );
  }
}
