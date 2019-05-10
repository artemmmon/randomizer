import 'package:bloc/bloc.dart';

class NumbersBloc extends Bloc<NumbersEvent, NumbersState> {
  @override
  NumbersState get initialState => NumbersState.initial();

  @override
  Stream<NumbersState> mapEventToState(NumbersEvent event) async* {
    switch (event.runtimeType) {
      case NumbersEventSetMin:
        yield currentState
          ..min = event.value
          ..didInit = true;
        break;
      case NumbersEventSetMax:
        yield currentState
          ..max = event.value
          ..didInit = true;
        break;
      case NumbersEventNewRandom:
        yield currentState
          ..random = event.value;
        break;
    }
  }
}

abstract class NumbersEvent {
  final int value;

  NumbersEvent(this.value);
}

class NumbersEventSetMin extends NumbersEvent {
  NumbersEventSetMin(int value) : super(value);
}

class NumbersEventSetMax extends NumbersEvent {
  NumbersEventSetMax(int value) : super(value);
}

class NumbersEventNewRandom extends NumbersEvent {
  NumbersEventNewRandom(int value) : super(value);
}

class NumbersState {
  int min;
  int max;
  int random;
  bool didInit;

  NumbersState._();

  factory NumbersState.initial() {
    return NumbersState._()
      ..min = 0
      ..max = 0
      ..random = 0
      ..didInit = false;
  }
}
