import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../splits/domain/models/split_participant_model.dart';

final tempParticipantsProvider =
    StateNotifierProvider<
        TempParticipantsNotifier,
        List<SplitParticipantModel>>((ref) {
  return TempParticipantsNotifier();
});

class TempParticipantsNotifier
    extends StateNotifier<List<SplitParticipantModel>> {
  TempParticipantsNotifier() : super([]);

  void addParticipant(String name) {
    final normalizedName =
        name.trim().toLowerCase();

    final alreadyExists = state.any(
      (participant) =>
          participant.name
              .trim()
              .toLowerCase() ==
          normalizedName,
    );

    if (alreadyExists) {
      return;
    }

    final participant =
        SplitParticipantModel(
      id: const Uuid().v4(),
      name: name.trim(),
      amount: 0,
      isSettled: false,
    );

    state = [...state, participant];
  }

  void removeParticipant(String id) {
    state = state
        .where(
          (participant) =>
              participant.id != id,
        )
        .toList();
  }

  void clearParticipants() {
    state = [];
  }

  void updateSplitAmounts(
    double totalAmount,
  ) {
    if (state.isEmpty) return;

    final splitAmount =
        totalAmount /
            (state.length + 1);

    state = state.map((participant) {
      return SplitParticipantModel(
        id: participant.id,
        name: participant.name,
        amount: splitAmount,
        isSettled:
            participant.isSettled,
      );
    }).toList();
  }

  bool containsParticipant(
    String name,
  ) {
    return state.any(
      (participant) =>
          participant.name
              .trim()
              .toLowerCase() ==
          name.trim().toLowerCase(),
    );
  }
}