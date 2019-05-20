import 'dart:math';

import 'package:bloc/bloc.dart';

const int DICE_MAX = 6;

class GambleBloc extends Bloc<GambleEvent, GambleState> {
  @override
  GambleState get initialState => GambleState.initial();

  @override
  Stream<GambleState> mapEventToState(GambleEvent event) async* {
    switch (event.runtimeType) {
      case GambleEventNewRandom:
        yield GambleState(currentState.amount, (event as GambleEventNewRandom).random);
        break;
      case GambleEventNewAmount:
        yield GambleState((event as GambleEventNewAmount).amount, currentState.random);
        break;
    }
  }
}

abstract class GambleEvent {}

class GambleEventNewRandom extends GambleEvent {
  final List<int> random;

  GambleEventNewRandom(this.random);
}

class GambleEventNewAmount extends GambleEvent {
  final int amount;

  GambleEventNewAmount(this.amount);
}

class GambleState {
  int amount;
  List<int> random;

  GambleState._();

  GambleState(this.amount, this.random);

  factory GambleState.initial() {
    final rand = Random();
    return GambleState._()
      ..amount = 2
      ..random = List.from(Iterable.generate(6, (value) => rand.nextInt(DICE_MAX)), growable: false);
  }
}
