import 'package:flutter/material.dart';
import 'package:m3t_attendee/features/user/view/user_avatar_button.dart';

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
        title: const Text('m3t Attendee'),
      ),
      body: const Center(
        child: Text('Welcome to m3t Attendee'),
      ),
    );
  }
}
