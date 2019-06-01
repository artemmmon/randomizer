import 'package:bloc/bloc.dart';
import 'package:jaguar_query_sqflite/jaguar_query_sqflite.dart';
import 'package:randomizer/data/CustomListBean.dart';
import 'package:randomizer/data/CustomListModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class CustomBloc extends Bloc<CustomEvent, CustomState> {
  CustomBloc() {
    _initDb();
  }

  // Db
  CustomListBean _customListBean;

  _initDb() async {
    var dbPath = await getDatabasesPath();
    final adapter = SqfliteAdapter(path.join(dbPath, "randomizer.db"));
    _customListBean = CustomListBean(adapter);
  }

  Future<List<CustomListModel>> fetchAllLists() async => _customListBean.getAll();

  Future storeList(CustomListModel model) async => _customListBean.insert(model);

  // State
  @override
  CustomState get initialState => CustomState.initial();

  @override
  Stream<CustomState> mapEventToState(CustomEvent event) async* {
    switch (event.runtimeType) {
      case CustomEventSetText:
        yield currentState..currentText = (event as CustomEventSetText).value;
        break;
      case CustomEventAddItem:
        final newList = currentState.customListModel.items..add((event as CustomEventAddItem).value);
        yield CustomState(currentState.currentText, currentState.customListModel..items = newList, null);
        break;
      case CustomEventRemoveItem:
        final newState = currentState..customListModel.items.remove((event as CustomEventRemoveItem).value);
        if (newState.customListModel.items.isEmpty) {
          newState.random = null;
        }
        yield newState;
        break;
      case CustomEventNewRandom:
        //todo need to store list only one time. Prevent copies
        // Store new list to db on new random
        var newModel = CustomListModel(_getModelName(), currentState.customListModel.items);
        storeList(newModel);

        yield CustomState(currentState.currentText, newModel, (event as CustomEventNewRandom).value);
        break;
      case CustomEventClearItems:
        yield CustomState(currentState.currentText, currentState.customListModel..items.clear(), null);
        break;
      case CustomEventClearRandom:
        yield CustomState(currentState.currentText, currentState.customListModel, null);
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _customListBean?.dispose();
  }
}

// Utils
String _getModelName() => DateTime.now().toString();
//

abstract class CustomEvent {}

class CustomEventSetText extends CustomEvent {
  final String value;

  CustomEventSetText(this.value);
}

class CustomEventAddItem extends CustomEvent {
  final String value;

  CustomEventAddItem(this.value);
}

class CustomEventRemoveItem extends CustomEvent {
  final String value;

  CustomEventRemoveItem(this.value);
}

class CustomEventClearItems extends CustomEvent {
  CustomEventClearItems();
}

class CustomEventNewRandom extends CustomEvent {
  final String value;

  CustomEventNewRandom(this.value);
}

class CustomEventClearRandom extends CustomEvent {
  CustomEventClearRandom();
}

class CustomState {
  String currentText;
  CustomListModel customListModel;
  String random;

  CustomState._();

  CustomState(this.currentText, this.customListModel, this.random);

  factory CustomState.initial() {
    return CustomState._()
      ..currentText = ""
      ..customListModel = CustomListModel(_getModelName(), List())
      ..random = null;
  }
}
