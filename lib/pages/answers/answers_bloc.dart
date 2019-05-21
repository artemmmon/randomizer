import 'dart:math';

import 'package:bloc/bloc.dart';

const ANSWERS = [
  // Absolute positive
  "It is certain",
  "It is decidedly so",
  "Without a doubt",
  "Yes — definitely",
  "You may rely on it",
  // Quite positive
  "As I see it, yes",
  "Most likely",
  "Outlook good",
  "Signs point to yes",
  "Yes",
  // Neutral
  "Reply hazy, try again",
  "Ask again later",
  "Better not tell you now",
  "Cannot predict now",
  "Concentrate and ask again",
  // Negative
  "Don’t count on it",
  "My reply is no",
  "My sources say no",
  "Outlook not so good",
  "Very doubtful"
];

class AnswersBloc extends Bloc<AnswersEvent, AnswersState> {
  final Random random = Random();

  @override
  AnswersState get initialState => AnswersState(_getRandomAnswer());

  @override
  Stream<AnswersState> mapEventToState(AnswersEvent event) async* {
    switch (event.runtimeType) {
      case AnswersEventNewRandom:
        yield AnswersState(_getRandomAnswer());
        break;
    }
  }

  String _getRandomAnswer() => ANSWERS[random.nextInt(ANSWERS.length)];
}

abstract class AnswersEvent {}

class AnswersEventNewRandom extends AnswersEvent {}

class AnswersState {
  final String answer;

  AnswersState(this.answer);
}
