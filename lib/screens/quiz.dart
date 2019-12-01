import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import '../shared/shared.dart';
import '../services/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

// Shared Data
class QuizState with ChangeNotifier {
  int _correct = 0;
  int _currentPage = 0;
  List<Option> _currentOptions = [];
  double _progress = 0;
  Option _selected;

  final PageController controller = PageController();

  get progress => _progress;
  get selected => _selected;

  set progress(double newValue) {
    _progress = newValue;
    notifyListeners();
  }

  set selected(Option newValue) {
    _selected = newValue;
    notifyListeners();
  }

  void nextPage() async {
    await controller.nextPage(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }
}

class QuizScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (_) => QuizState(),
      child: FutureBuilder(
        future: Collection<Question>(path: 'quizzes').getData(),
        builder: (BuildContext context, AsyncSnapshot snap) {
          var state = Provider.of<QuizState>(context);

          if (!snap.hasData || snap.hasError) {
            return LoadingScreen();
          } else {
            List<Question> quizs = snap.data;
            return Scaffold(
              appBar: AppBar(
                title: AnimatedProgressbar(value: state.progress)
              ),
              body: PageView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                controller: state.controller,
                onPageChanged: (int idx) =>
                    state.progress = (state._correct / (quizs.length)),
                itemBuilder: (BuildContext context, int idx) {
                  if (idx > 0 && idx != state._currentPage && idx <= quizs.length) {
                    state._currentPage = idx;
                    state._currentOptions = quizs[idx-1].options..shuffle();
                    state.selected = null;
                  }

                  if (idx == 0) {   
                    return StartPage(totalQuizCount: quizs.length);
                  } else if (idx == quizs.length + 1) {        
                    return CongratsPage(quizzes: quizs);
                  } else {
                    return QuestionPage(
                      question: quizs[idx - 1].text, 
                      options: state._currentOptions, 
                      totalQuestioins: quizs.length
                    );
                  }
                },
              ),
              bottomNavigationBar: AppBottomNav(),
            );
          }
        },
      ),
    );
  }
}

class StartPage extends StatelessWidget {
  final int totalQuizCount;
  final PageController controller;
  final String timeLabel = formatDate(DateTime.now(), [H, " : ", n, " : ", s]);

  StartPage({this.controller, this.totalQuizCount});

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<QuizState>(context);

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Tiempo hasta reincio: ", style: Theme.of(context).textTheme.headline),
          Text(timeLabel, style: Theme.of(context).textTheme.headline),
          Divider(),

          Text("Numero de preguntas: $totalQuizCount", style: Theme.of(context).textTheme.title),
          Divider(),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton.icon(
                onPressed: state.nextPage,
                label: Text('Start Quiz!'),
                icon: Icon(Icons.poll),
                color: Colors.green,
              )
            ],
          )
        ],
      ),
    );
  }
}

class CongratsPage extends StatelessWidget {
  final List<Question> quizzes;
  CongratsPage({this.quizzes});

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<QuizState>(context);
    var corrects = state._correct;
    var total = quizzes.length;

    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Respuesta incorrecta,',
            style: Theme.of(context).textTheme.headline,
            textAlign: TextAlign.center,
          ),
          Text(
            '$corrects correctas de $total',
            style: Theme.of(context).textTheme.headline,
            textAlign: TextAlign.center,
          ),
          Divider(),

          FlatButton.icon(
            color: Colors.green,
            icon: Icon(Icons.replay),
            label: Text('Vuelve a intentarlo'),
            onPressed: () {
              Report report = Provider.of<Report>(context);
              report.total = state._correct;

              _updateUserReport(state._correct);
              Navigator.pushReplacementNamed(context, '/quiz');
            },
          )
        ],
      ),
    );
  }

  /// Database write to update report doc when complete
  Future<void> _updateUserReport(int succ) {
    return Global.reportRef.upsert(
      ({
        'total': succ
      }),
    );
  }
}

class QuestionPage extends StatelessWidget {
  final String question;
  final int totalQuestioins;
  final List<Option> options;
  QuestionPage({this.question, this.options, this.totalQuestioins});

  Iterable randomKeys(Map map) sync* {
    var keys = map.keys.toList();
    var rnd = new Random();
    while (keys.length > 0) {
      var index = rnd.nextInt(keys.length);
      var key = keys[index];
      keys[index] = keys.last;
      keys.length--;
      yield key;
    }
  } 

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<QuizState>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Text(question),
          ),
        ),
        Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: options.map((opt) {
              return Container(
                height: 90,
                margin: EdgeInsets.only(bottom: 10),
                color: Colors.black26,
                child: InkWell(
                  onTap: () {
                    if (state.selected == null) {
                      state.selected = opt;
                      _bottomSheet(context, opt);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                            state.selected == opt
                                ? FontAwesomeIcons.checkCircle
                                : FontAwesomeIcons.circle,
                            size: 30),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 16),
                            child: Text(
                              opt.value,
                              style: Theme.of(context).textTheme.body2,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }
  
  /// Database write to update report doc when complete
  Future<void> _updateUserReport(int succ) {
    return Global.reportRef.upsert(
      ({
        'total': succ
      }),
    );
  }

  /// Bottom sheet shown when Question is answered
  _bottomSheet(BuildContext context, Option opt) {
    bool correct = opt.correct;
    var state = Provider.of<QuizState>(context);
    if (correct) {
      state._correct += 1;
    }
    if (state._correct == totalQuestioins) {
      Report report = Provider.of<Report>(context);
      report.total = state._correct;
      
      _updateUserReport(state._correct);
      Navigator.pushReplacementNamed(context, '/post');
      return;
    }

    showBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(correct ? 'Correct!' : 'Wrong'),
              FlatButton(
                color: correct ? Colors.green : Colors.red,
                child: Text(
                  correct ? 'Next' : 'Try again!',
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  if (correct) {
                    state.nextPage();
                    Navigator.pop(context);
                  } else {                    
                    Report report = Provider.of<Report>(context);
                    report.total = state._correct;

                    _updateUserReport(state._correct);
                    Navigator.pushReplacementNamed(context, '/quiz');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
