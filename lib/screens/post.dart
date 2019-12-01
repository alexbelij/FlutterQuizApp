import 'package:flutter/material.dart';
import '../services/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class PostQuizScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<PostQuizScreen>{

  String title = "";
  List<String> values = ["", "", "", ""];

  void _addClicked() {
    Global.guizzesRef.addQuiz({
      'text': title,
      'options': [{
          'value': values[0],
          'detail': '',
          'correct': true
        }, {
          'value': values[1],
          'detail': '',
          'correct': false
        }, {
          'value': values[2],
          'detail': '',
          'correct': false
        }, {
          'value': values[3],
          'detail': '',
          'correct': false
        }
      ]
    });

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/quiz',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {  
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    var userId = user.displayName;

    return Scaffold(

      body: Container(
        padding: new EdgeInsets.all(32.0),
        child: 
          SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,

            children: <Widget>[
              Text('!Enhorabuena!', style: new TextStyle(
                fontSize: 22.0,
                height: 2.0     
              )),
              Text('Todas las respuestas correctas!', style: new TextStyle(
                fontSize: 22.0,
                height: 1.0     
              )),
              Divider(),

              Text(
                'Nombre usuario: $userId'
              ),
              Divider(),

              Text('Pregunta', style: new TextStyle(
                fontSize: 20.0,
                height: 2.0     
              )),

              TextField(
                onChanged: (val) {
                  title = val;
                },
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Pregunta',                  
                ),
              ),

              Divider(),
              Text('Respuestas', style: new TextStyle(
                fontSize: 18.0,
                height: 2.0                
              )),
              Divider(),
              
              TextField(
                onChanged: (val) {
                  values[0] = val;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Correct Answer',
                ),
              ),

              Divider(),

              TextField(
                onChanged: (val) {
                  values[1] = val;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Wrong Answer 1',
                ),
              ),

              SizedBox(height: 10),

              TextField(
                onChanged: (val) {
                  values[2] = val;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Wrong Answer 2',
                ),
              ),

              SizedBox(height: 10),

              TextField(
                onChanged: (val) {
                  values[3] = val;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Wrong Answer 3',
                ),
              ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  MaterialButton(
                    child: Text("Add question"),
                    onPressed: _addClicked,
                  ),
                  MaterialButton(
                    child: Text("Canel"),
                    onPressed: (){
                      Navigator.pushNamedAndRemoveUntil(context, '/quiz', (route) => false,);
                    },
                  )
                ]
              )
          ],)
          )
      )
    );
  }
}