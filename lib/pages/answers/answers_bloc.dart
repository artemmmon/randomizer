import 'dart:math';
import 'dart:ui';

import 'package:bloc/bloc.dart';

const ANSWERS_EN = [
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

const ANSWERS_RU = [
  // Absolute positive
  "Бесспорно",
  "Предрешено",
  "Никаких сомнений",
  "Определённо да",
  "Можешь быть уверен в этом",
  // Quite positive
  "Мне кажется — «да»",
  "Вероятнее всего",
  "Хорошие перспективы",
  "Знаки говорят — «да»",
  "Да",
  // Neutral
  "Пока не ясно, попробуй снова",
  "Спроси позже",
  "Лучше не рассказывать",
  "Сейчас нельзя предсказать",
  "Сконцентрируйся и спроси опять",
  // Negative
  "Даже не думай",
  "Мой ответ — «нет»",
  "По моим данным — «нет»",
  "Перспективы не очень хорошие",
  "Весьма сомнительно"
];

const ANSWERS_UK = [
  // Absolute positive
  "Безперечно",
  "Дійсно так",
  "Жодних сумнівів",
  "Безумовно так",
  "Можеш бути впевнений в цьому",
  // Quite positive
  "Мені здається «так»",
  "Ймовірніше за все",
  "Хороші перспективи",
  "Знаки кажуть - «так»",
  "Так",
  // Neutral
  "Поки не ясно, спробуй знову",
  "Запитай пізніше",
  "Краще не розповідати",
  "Зараз не можна передбачити",
  "Сконцентруйся і запитай знову",
  // Negative
  "Навіть не думай",
  "Моя відповідь «ні»",
  "За моїми даними - «ні»",
  "Перспективи не дуже хороші",
  "Дуже сумнівно"
];

class AnswersBloc extends Bloc<AnswersEvent, AnswersState> {
  final Random random = Random();
  List<String> answers;

  AnswersBloc(this.answers);

  factory AnswersBloc.create(Locale locale) {
    List<String> answers;
    switch (locale.languageCode) {
      case "en":
        answers = ANSWERS_EN;
        break;
      case "ru":
        answers = ANSWERS_RU;
        break;
      case "uk":
        answers = ANSWERS_UK;
        break;
      default:
        answers = ANSWERS_EN;
        break;
    }

    return AnswersBloc(answers);
  }

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

  String _getRandomAnswer() {
    return answers[random.nextInt(answers.length)];
  }
}

abstract class AnswersEvent {}

class AnswersEventNewRandom extends AnswersEvent {}

class AnswersState {
  final String answer;

  AnswersState(this.answer);
}
