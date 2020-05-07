import 'package:dailytask/CirclePainter.dart';
import 'package:dailytask/edit_page.dart';
import 'package:dailytask/timer.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Task',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _score = 0;
  Directory _dir;
  String _fileName = "taskData.json";
  File _jsonFile;
  Map _taskMap;
  List nameList = [""];
  Map timeDoneMap = new Map();
  Map<String,int> scoreMap = new Map();

  @override
  void initState(){
    super.initState();
    getApplicationDocumentsDirectory().then((d){
      _dir = d;
      _jsonFile = new File(_dir.path+"/"+_fileName);
      if(!_jsonFile.existsSync()){
        _taskMap = {"":null};
      }
      else{
        try{
          _taskMap = jsonDecode(_jsonFile.readAsStringSync());
          setState(() {
            nameList = _taskMap.keys.toList();
          });
          for(int i = 0;i<nameList.length;i++){
            scoreMap[nameList[i]] = 0;
            timeDoneMap[nameList[i]] = 0;//TODO need to read from file
          }
        }catch(e){
          print("json file error: "+ _jsonFile.readAsStringSync());
          print(e);
        }
      }
    });
  }

  void nameListUpdate(){
    try{
      _taskMap = jsonDecode(_jsonFile.readAsStringSync());
      setState(() {
        nameList = _taskMap.keys.toList();
        _score=updateScore();
      });
    }catch(e) {
      print("json file error: " + _jsonFile.readAsStringSync());
      print(e);
    }
  }

  //Navigation and pass value method
  void navigatorValue(BuildContext context, String taskName)async{
    var completedMin = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context)=> TimerPage(title: "TimerPage")),
    );
    //TODO updateScore
    int addedMin = completedMin;
    updateScoreMap(taskName, addedMin);

  }

  void navigatorPush() async{
    var newName = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context)=> EditPage(title: "EditPage")),
    );
    if(newName!=""){
      scoreMap[newName]=0;
      timeDoneMap[newName]=0;
    }
    nameListUpdate();
  }

  //update the totalScore, scoreMap and each completed time
  void updateScoreMap(String taskName, int addedMin){
    timeDoneMap[taskName] += addedMin;
    Map selectedTask = _taskMap[taskName];
    if(selectedTask["minutes"]!=""){
      if(timeDoneMap[taskName]>=int.parse(selectedTask["minutes"])){
        scoreMap[taskName] = 100;
      }
      else{
        scoreMap[taskName] = (timeDoneMap[taskName]*100/int.parse(selectedTask["minutes"])).round();
      }
    }
    setState(() {
      _score=updateScore();
    });
  }
  int updateScore(){
    int sum =0;
    for(int i = 0; i<nameList.length; i++){
      sum+=scoreMap[nameList[i]];
    }
    return (sum*100/(100*nameList.length)).round();
  }

  //TaskMenu
  createMenu(BuildContext context, int index){
    showBottomSheet(context: context,
        backgroundColor: Colors.grey,
        builder: (BuildContext context){
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.access_alarm, color: Colors.red),
                title: Text("Start Working"),
                onTap: (){
                  Navigator.pop(context);
                  navigatorValue(context, nameList[index]);
                },
              ),
              ListTile(
                leading: Icon(Icons.check, color: Colors.red,),
                title: Text("Mark as completed"),
                onTap: (){
                  Navigator.pop(context);
                  scoreMap[nameList[index]]=100;
                  setState(() {
                    _score=updateScore();
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.edit, color: Colors.red),
                title: Text("Edit"),
                onTap: (){
                  print("Edit");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text("Delete  "+nameList[index]),
                onTap: (){
                  _deleteTasks(nameList[index]);
                  nameListUpdate();
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  //Delete Tasks
  void _deleteTasks(String taskID){
    if(_jsonFile.existsSync()){
      try{
        Map dataToWrite = jsonDecode(_jsonFile.readAsStringSync());
        dataToWrite.remove(taskID);
        _jsonFile.writeAsStringSync(jsonEncode(dataToWrite));
      }
      catch(e){
        print(e);
      }
    }
    scoreMap.remove(taskID);
    timeDoneMap.remove(taskID);
  }

  //main widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomPaint(
              foregroundPainter: CirclePainter(_score.toDouble()),
              child: Container(
                width: 300,
                height: 300,
                child: Center(
                  child: Text(
                      '$_score%',
                    style: TextStyle(
                      fontSize: 90,
                      fontWeight: FontWeight.w200
                    ),
                  ),
                )
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: nameList.length,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      child: FlatButton(onPressed: (){
                        createMenu(context, index);
                      },
                          child: Text(nameList[index],
                            style: scoreMap[nameList[index]]==100?
                            TextStyle(
                                fontSize: 20,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.black.withOpacity(0.5)):
                            TextStyle(color: Colors.black)
                          ),
                      ),
                    );
                  }
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          navigatorPush();
        },
        tooltip: 'Edit',
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
