import 'package:bloc/bloc.dart';

class CustomBloc extends Bloc<CustomEvent, CustomState> {
  @override
  CustomState get initialState => CustomState.initial();

  @override
  Stream<CustomState> mapEventToState(CustomEvent event) async* {
    switch (event.runtimeType) {
      case CustomEventSetText:
        yield currentState..currentText = event.value;
        break;
      case CustomEventAddItem:
        yield currentState..items.add(event.value);
        break;
      case CustomEventRemoveItem:
        final newState = currentState..items.remove(event.value);
        if (newState.items.isEmpty) {
          newState.random = null;
        }
        yield newState;
        break;
      case CustomEventNewRandom:
        yield currentState
          ..random = event.value
          ..items.clear();
        break;
      case CustomEventClearItems:
        yield currentState
          ..items.clear()
          ..random = null;
        break;
    }
  }
}

abstract class CustomEvent {
  final String value;

  CustomEvent(this.value);
}

class CustomEventSetText extends CustomEvent {
  CustomEventSetText(String value) : super(value);
}

class CustomEventAddItem extends CustomEvent {
  CustomEventAddItem(String value) : super(value);
}

class CustomEventRemoveItem extends CustomEvent {
  CustomEventRemoveItem(String value) : super(value);
}

class CustomEventClearItems extends CustomEvent {
  CustomEventClearItems() : super(null);
}

class CustomEventNewRandom extends CustomEvent {
  CustomEventNewRandom(String value) : super(value);
}

class CustomState {
  String currentText;
  List<String> items;
  String random;

  CustomState._();

  factory CustomState.initial() {
    return CustomState._()
      ..currentText = ""
      ..items = List()
      ..random = null;
  }
}
