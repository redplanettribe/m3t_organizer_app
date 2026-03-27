import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_organizer/features/deliverable_giveaway/deliverable_giveaway.dart';
import 'package:mocktail/mocktail.dart';

class _MockEventsRepository extends Mock implements EventsRepository {}

void main() {
  group('DeliverableGiveawayCubit', () {
    late EventsRepository eventsRepository;

    const deliverables = [
      EventDeliverable(id: 'd1', name: 'T-shirt'),
      EventDeliverable(id: 'd2', name: 'Sticker pack'),
    ];

    late DeliverableGiveaway successGiveaway;

    setUp(() {
      eventsRepository = _MockEventsRepository();
      successGiveaway = DeliverableGiveaway(
        id: 'g1',
        eventID: 'e1',
        deliverableID: 'd1',
        userID: 'user-1',
        givenBy: 'admin',
        createdAt: DateTime.utc(2026),
      );
    });

    DeliverableGiveawayCubit buildCubit() => DeliverableGiveawayCubit(
      eventID: 'e1',
      eventsRepository: eventsRepository,
    );

    group('loadDeliverables', () {
      blocTest<DeliverableGiveawayCubit, DeliverableGiveawayState>(
        'emits loading then deliverables on success',
        build: buildCubit,
        setUp: () {
          when(
            () => eventsRepository.getEventDeliverables(
              eventID: any(named: 'eventID'),
            ),
          ).thenAnswer((_) async => deliverables);
        },
        act: (cubit) => cubit.loadDeliverables(),
        expect: () => <DeliverableGiveawayState>[
          const DeliverableGiveawayState(loadingList: true),
          const DeliverableGiveawayState(
            deliverables: deliverables,
          ),
        ],
      );

      blocTest<DeliverableGiveawayCubit, DeliverableGiveawayState>(
        'emits errorMessage when EventsFailure occurs',
        build: buildCubit,
        setUp: () {
          when(
            () => eventsRepository.getEventDeliverables(
              eventID: any(named: 'eventID'),
            ),
          ).thenThrow(EventsNetworkError());
        },
        act: (cubit) => cubit.loadDeliverables(),
        expect: () => <DeliverableGiveawayState>[
          const DeliverableGiveawayState(loadingList: true),
          const DeliverableGiveawayState(
            errorMessage:
                'A network error occurred. Please try again.',
          ),
        ],
      );
    });

    group('onUserIDScanned', () {
      blocTest<DeliverableGiveawayCubit, DeliverableGiveawayState>(
        'records giveaway when deliverable is selected',
        build: buildCubit,
        setUp: () {
          when(
            () => eventsRepository.getEventDeliverables(
              eventID: any(named: 'eventID'),
            ),
          ).thenAnswer((_) async => deliverables);
          when(
            () => eventsRepository.giveDeliverableToUser(
              eventID: any(named: 'eventID'),
              deliverableID: any(named: 'deliverableID'),
              userID: any(named: 'userID'),
            ),
          ).thenAnswer((_) async => successGiveaway);
        },
        act: (cubit) async {
          await cubit.loadDeliverables();
          cubit.selectDeliverable(deliverables.first);
          await cubit.onUserIDScanned('  user-1  ');
        },
        expect: () => <DeliverableGiveawayState>[
          const DeliverableGiveawayState(loadingList: true),
          const DeliverableGiveawayState(
            deliverables: deliverables,
          ),
          DeliverableGiveawayState(
            deliverables: deliverables,
            selectedDeliverable: deliverables.first,
          ),
          DeliverableGiveawayState(
            deliverables: deliverables,
            selectedDeliverable: deliverables.first,
            loadingGiveaway: true,
          ),
          DeliverableGiveawayState(
            deliverables: deliverables,
            selectedDeliverable: deliverables.first,
            latestGiveaway: DeliverableGiveaway(
              id: successGiveaway.id,
              eventID: successGiveaway.eventID,
              deliverableID: successGiveaway.deliverableID,
              userID: successGiveaway.userID,
              givenBy: successGiveaway.givenBy,
              createdAt: successGiveaway.createdAt,
              deliverableName: deliverables.first.name,
            ),
          ),
        ],
      );

      blocTest<DeliverableGiveawayCubit, DeliverableGiveawayState>(
        'sets giveawayScanError when attendee is ineligible (422)',
        build: buildCubit,
        setUp: () {
          when(
            () => eventsRepository.getEventDeliverables(
              eventID: any(named: 'eventID'),
            ),
          ).thenAnswer((_) async => deliverables);
          when(
            () => eventsRepository.giveDeliverableToUser(
              eventID: any(named: 'eventID'),
              deliverableID: any(named: 'deliverableID'),
              userID: any(named: 'userID'),
            ),
          ).thenThrow(EventsUnprocessableEntity());
        },
        act: (cubit) async {
          await cubit.loadDeliverables();
          cubit.selectDeliverable(deliverables.first);
          await cubit.onUserIDScanned('user-x');
        },
        expect: () => <DeliverableGiveawayState>[
          const DeliverableGiveawayState(loadingList: true),
          const DeliverableGiveawayState(
            deliverables: deliverables,
          ),
          DeliverableGiveawayState(
            deliverables: deliverables,
            selectedDeliverable: deliverables.first,
          ),
          DeliverableGiveawayState(
            deliverables: deliverables,
            selectedDeliverable: deliverables.first,
            loadingGiveaway: true,
          ),
          DeliverableGiveawayState(
            deliverables: deliverables,
            selectedDeliverable: deliverables.first,
            giveawayScanError:
                'This attendee must be registered and checked in to the event '
                'before they can receive this item.',
          ),
        ],
      );

      blocTest<DeliverableGiveawayCubit, DeliverableGiveawayState>(
        'sets pendingGiveawayRetryUserID when already given (409)',
        build: buildCubit,
        setUp: () {
          when(
            () => eventsRepository.getEventDeliverables(
              eventID: any(named: 'eventID'),
            ),
          ).thenAnswer((_) async => deliverables);
          when(
            () => eventsRepository.giveDeliverableToUser(
              eventID: any(named: 'eventID'),
              deliverableID: any(named: 'deliverableID'),
              userID: any(named: 'userID'),
            ),
          ).thenThrow(EventsDeliverableAlreadyGiven());
        },
        act: (cubit) async {
          await cubit.loadDeliverables();
          cubit.selectDeliverable(deliverables.first);
          await cubit.onUserIDScanned('user-dup');
        },
        expect: () => <DeliverableGiveawayState>[
          const DeliverableGiveawayState(loadingList: true),
          const DeliverableGiveawayState(
            deliverables: deliverables,
          ),
          DeliverableGiveawayState(
            deliverables: deliverables,
            selectedDeliverable: deliverables.first,
          ),
          DeliverableGiveawayState(
            deliverables: deliverables,
            selectedDeliverable: deliverables.first,
            loadingGiveaway: true,
          ),
          DeliverableGiveawayState(
            deliverables: deliverables,
            selectedDeliverable: deliverables.first,
            pendingGiveawayRetryUserID: 'user-dup',
          ),
        ],
      );
    });

    group('submitGiveWithGiveAnyway', () {
      blocTest<DeliverableGiveawayCubit, DeliverableGiveawayState>(
        'calls repository with giveAnyway true and emits success',
        build: buildCubit,
        setUp: () {
          when(
            () => eventsRepository.getEventDeliverables(
              eventID: any(named: 'eventID'),
            ),
          ).thenAnswer((_) async => deliverables);
          when(
            () => eventsRepository.giveDeliverableToUser(
              eventID: any(named: 'eventID'),
              deliverableID: any(named: 'deliverableID'),
              userID: any(named: 'userID'),
              giveAnyway: true,
            ),
          ).thenAnswer((_) async => successGiveaway);
        },
        act: (cubit) async {
          await cubit.loadDeliverables();
          cubit.selectDeliverable(deliverables.first);
          await cubit.submitGiveWithGiveAnyway(userID: 'user-1');
        },
        expect: () => <DeliverableGiveawayState>[
          const DeliverableGiveawayState(loadingList: true),
          const DeliverableGiveawayState(
            deliverables: deliverables,
          ),
          DeliverableGiveawayState(
            deliverables: deliverables,
            selectedDeliverable: deliverables.first,
          ),
          DeliverableGiveawayState(
            deliverables: deliverables,
            selectedDeliverable: deliverables.first,
            loadingGiveaway: true,
          ),
          DeliverableGiveawayState(
            deliverables: deliverables,
            selectedDeliverable: deliverables.first,
            latestGiveaway: DeliverableGiveaway(
              id: successGiveaway.id,
              eventID: successGiveaway.eventID,
              deliverableID: successGiveaway.deliverableID,
              userID: successGiveaway.userID,
              givenBy: successGiveaway.givenBy,
              createdAt: successGiveaway.createdAt,
              deliverableName: deliverables.first.name,
            ),
          ),
        ],
      );
    });
  });
}
