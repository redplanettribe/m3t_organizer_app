import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/features/events/events.dart';

final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = EventsCubit(
          eventsRepository: context.read<EventsRepository>(),
        );
        unawaited(cubit.loadManagedEvents());
        return cubit;
      },
      child: const EventsPage(),
    );
  }
}
