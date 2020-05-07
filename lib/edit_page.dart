import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class EditPage extends StatefulWidget {
  EditPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  File jsonFile;
  Directory dir;
  String fileName = "taskData.json";
  Map<String,String>newdata = {
    "name":"",
    "dueDate" :"",
    "minutes":"",
    "workDay":""
  };

  @override
  void initState(){
    super.initState();
    getApplicationDocumentsDirectory().then((d){
      dir = d;
      jsonFile = new File(dir.path+"/"+fileName);
    });
  }

  void writeToFile(Map<String,String> newdata){
    if(jsonFile.existsSync()){
      Map dataToWrite = jsonDecode(jsonFile.readAsStringSync());
      dataToWrite[newdata["name"]] = newdata;
      jsonFile.writeAsStringSync(jsonEncode(dataToWrite));
    }
    else{
      Map<String,Map> dataToWrite = {newdata["name"]:newdata};
      jsonFile.createSync();
      jsonFile.writeAsStringSync(jsonEncode(dataToWrite));
    }
  }

  void dataUpdate(){
    newdata["name"] = _nameController.text.toString();
    newdata["minutes"] = _minController.text.toString();
    newdata["workDay"]="";
    for(int i=0;i<7;i++){
      if(weekdays[i]){
        newdata["workDay"]+=i.toString();
      }
    }

  }

  bool nameCheck(){
    if(newdata["name"]=="" || newdata["name"].startsWith(' ')){
      return false;
    }
    return true;
  }

  createAlertDialog(BuildContext context){
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Illegal Name"),
        content: Text("Task name cannot be empty or begin with spaces."),
        actions: <Widget>[
          MaterialButton(
            elevation: 5,
            child: Text("Back"),
            onPressed: (){
              Navigator.pop(context);
            },
          )
        ],
      );
    });
  }

  //TextEditingControllers
  var _nameController = TextEditingController();
  var _minController = TextEditingController();
  //work day bool 0:sunday...6:saturday
  List<bool> weekdays = [false,false,false,false,false,false,false];


  //select due date function
  //format of duedata: year,month,day
  Future<DateTime> selectDate(BuildContext context) async{
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(new Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(new Duration(days: 1000)));
    if(picked != null){
      newdata["dueDate"] = picked.year.toString()+","+picked.month.toString()+","+picked.day.toString();
    }
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(

        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _nameController,
                obscureText: false,
                maxLength: 28,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                ),
              ),
              RaisedButton(
                onPressed: ()=>selectDate(context),
                child: Text('Select due date')
              ),
              TextField(
                controller: _minController,
                obscureText: false,
                maxLength: 3,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Minutes need per day',
                ),
              ),
              Text(
                "Select work days"
              ),
              ButtonBar(
                buttonMinWidth: 30,
                children: <Widget>[
                  FlatButton(onPressed: (){
                    setState(() {
                      weekdays[0]=!weekdays[0];
                    });
                    },
                      child: Text("S"),
                      color: weekdays[0]?Color(0xFF42A5F5):Color(0xFFFFFF),
                  ),
                  FlatButton(onPressed: (){
                    setState(() {
                      weekdays[1]=!weekdays[1];
                    });
                  },
                    child: Text("M"),
                    color: weekdays[1]?Color(0xFF42A5F5):Color(0xFFFFFF),
                  ),
                  FlatButton(onPressed: (){
                    setState(() {
                      weekdays[2]=!weekdays[2];
                    });
                  },
                      child: Text("T"),
                      color: weekdays[2]?Color(0xFF42A5F5):Color(0xFFFFFF),
                  ),
                  FlatButton(onPressed: (){
                    setState(() {
                      weekdays[3]=!weekdays[3];
                    });
                  },
                      child: Text("W"),
                    color: weekdays[3]?Color(0xFF42A5F5):Color(0xFFFFFF),
                  )
                  ,FlatButton(onPressed: (){
                    setState(() {
                      weekdays[4]=!weekdays[4];
                    });
                  },
                      child: Text("T"),
                    color: weekdays[4]?Color(0xFF42A5F5):Color(0xFFFFFF),
                  ),
                  FlatButton(onPressed: (){
                    setState(() {
                      weekdays[5]=!weekdays[5];
                    });
                  },
                      child: Text("F"),
                    color: weekdays[5]?Color(0xFF42A5F5):Color(0xFFFFFF),
                  ),
                  FlatButton(onPressed: (){
                    setState(() {
                      weekdays[6]=!weekdays[6];
                    });
                  },
                      child: Text("S"),
                    color: weekdays[6]?Color(0xFF42A5F5):Color(0xFFFFFF),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(onPressed: (){
                    dataUpdate();
                    if(!nameCheck()){
                      createAlertDialog(context);
                    }
                    else{
                      writeToFile(newdata);
                      Navigator.pop(context,newdata["name"]);
                      //back to home page
                    }
                  },
                      child: Text("Save")
                  ),
                  FlatButton(onPressed: (){
                    Navigator.pop(context,"");
                  },
                    child: Text("Cancel"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
