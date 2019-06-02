import 'package:bloc/bloc.dart';
import 'package:jaguar_query_sqflite/jaguar_query_sqflite.dart';
import 'package:randomizer/data/custom_list_bean.dart';
import 'package:randomizer/data/custom_list_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:date_format/date_format.dart' as dateFormat;
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
        // Store new list to db on new random
        var newModel = CustomListModel(_getModelName(), currentState.customListModel.items);
        yield CustomState(currentState.currentText, newModel, (event as CustomEventNewRandom).value);

        storeList(newModel);
        break;
      case CustomEventClearItems:
        yield CustomState(currentState.currentText, currentState.customListModel..items.clear(), null);
        break;
      case CustomEventClearRandom:
        yield CustomState(currentState.currentText, currentState.customListModel, null);
        break;
      case CustomEventPickModel:
        yield CustomState(currentState.currentText, (event as CustomEventPickModel).value, null);
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
String _getModelName() {
  var format = [
    dateFormat.dd,
    ".",
    dateFormat.mm,
    ".",
    dateFormat.yyyy,
    " ",
    dateFormat.hh,
    ":",
    dateFormat.nn,
  ];
  return dateFormat.formatDate(DateTime.now(), format);
}
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

class CustomEventPickModel extends CustomEvent {
  final CustomListModel value;

  CustomEventPickModel(this.value);
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
