import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/combination_service.dart';

enum CombinationStatus { initial, loading, success, failure }

class CombinationState {
  final CombinationStatus status;
  final String errorMessage;

  CombinationState({
    this.status = CombinationStatus.initial,
    this.errorMessage = '',
  });

  CombinationState copyWith({
    CombinationStatus? status,
    String? errorMessage,
  }) {
    return CombinationState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

abstract class CombinationEvent {}

class CreateCombination extends CombinationEvent {
  final String name;
  final String description;
  final List<int> clothingIds;

  CreateCombination(this.name, this.description, this.clothingIds);
}

class CombinationBloc extends Bloc<CombinationEvent, CombinationState> {
  final CombinationService combinationService;

  CombinationBloc(this.combinationService) : super(CombinationState()) {
    on<CreateCombination>((event, emit) async {
      emit(state.copyWith(status: CombinationStatus.loading));
      try {
        await combinationService.createCombination(
            event.name, event.description, event.clothingIds);
        emit(state.copyWith(status: CombinationStatus.success));
      } catch (e) {
        emit(state.copyWith(
          status: CombinationStatus.failure,
          errorMessage: e.toString(),
        ));
      }
    });
  }
}