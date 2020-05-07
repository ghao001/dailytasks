import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class TimerPage extends StatefulWidget {
  TimerPage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _TimerState createState() => _TimerState();

}


class _TimerState extends State<TimerPage> with TickerProviderStateMixin{

  AnimationController controller;
  Duration duration;


  String get timerString {
    duration = controller.duration * controller.value;
    return '${duration.inHours}:${(duration.inMinutes%60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(minutes: totalMin),
    );

  }


  bool finishSelect=false;
  int selectedHour=0;
  int selectedMin=1;
  int totalMin = 1;
  int completedMin=0;

  AnimatedBuilder timerWidget(){
    return new AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget child) {
          return Text(
            timerString,
            style: Theme.of(context).textTheme.display4,
          );
        });
  }

  Widget picker(){
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        NumberPicker.integer(initialValue: selectedHour, minValue: 0, maxValue: 5,
            onChanged: (newValue) =>
                setState(() => selectedHour = newValue)),
        Text("Hrs"),
        NumberPicker.integer(initialValue: selectedMin, minValue: 1, maxValue: 59,
            onChanged: (newValue) =>
                setState(() => selectedMin = newValue)),
        Text("Mins")
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    Widget selectToTimer;
    if(finishSelect){
      selectToTimer = timerWidget();
    }
    else{
      selectToTimer = picker();
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Count Down",
                    style: themeData.textTheme.subhead,
                  ),
                  selectToTimer,
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FloatingActionButton(
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (BuildContext context, Widget child) {
                        return Icon(controller.isAnimating
                            ? Icons.pause
                            : Icons.play_arrow);

                      },
                    ),
                    onPressed: () {
                      setState(() {
                        finishSelect = true;
                      });
                      totalMin = selectedHour*60+selectedMin;
                      controller.duration=new Duration(minutes: totalMin);
                      if (controller.isAnimating) {
                        controller.stop(canceled: true);
                      } else {
                        controller.reverse(
                            from: controller.value == 0.0
                                ? 1.0
                                : controller.value);
                      }
                    },
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                    onPressed: () {
                      completedMin = totalMin-duration.inMinutes;
                      Navigator.pop(context, completedMin);
                    },
                    child: Text("Save")),
                FlatButton(
                  onPressed: () {
                    completedMin = 0;
                    print(duration.inSeconds);
                    Navigator.pop(context, completedMin);
                  },
                  child: Text("Cancel"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
