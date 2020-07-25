import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async{
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Milk Bill',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Milk Bill'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  Map<DateTime, List> _events;
  Map<String, List> _event;
  List _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;
  var sel=DateTime.now().toString().substring(0,10);
  List _upd;
  List<String> a,b;
  var updv='0',_rate='0';
  double q=0.0,bil;
  var monthsl= ['Month','January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'];
  String choice="";
  var _mon='Month',_yr='Year';
  final quanholder = TextEditingController();

  @override
  void initState() {
    super.initState();

    final _selectedDay = DateTime.now();
    _events = {
      DateTime.parse("2019-10-06") : ['0'],
      /*_selectedDay.subtract(Duration(days: 45)): ['45'],
      _selectedDay.subtract(Duration(days: 5)): [val[5]],
      _selectedDay.subtract(Duration(days: 3)): [val[3]],
      _selectedDay.subtract(Duration(days: 2)): [val[2]],
      _selectedDay.subtract(Duration(days: 1)): [val[1]],
      _selectedDay: [val[0]],*/
    };
    _loadCounter();
    _selectedEvents = _events[_selectedDay] ?? [];
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }
  _loadCounter() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        a = prefs.getStringList('key');
        b = prefs.getStringList('value');
      });
      print("Load");
      print(a);
      print(b);
      for (int i = 0; i < a.length; i++) {
        _events[DateTime.parse(a[i])] = [b[i]];
      }
    }
    catch(e){
      print(e);
    }
  }
  storage() async{
    var s=_events.keys.toList();
    int x=s.length;
    print(x);
    print(s.length);
    List<String> a=new List(x);
    List<String> b=new List(x);
    for(int i =0;i<x;i++){
      b[i]=_events[s[i]][0].toString();
      a[i]=s[i].toString();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setStringList('key', a);
      prefs.setStringList('value', b);
    });
  }
  void _onDaySelected(DateTime day, List events) {
    sel=day.toString().substring(0,10);
    quanholder.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
    _loadCounter();
  }

  @override
  Widget build(BuildContext context) {
    //print(_events);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepOrange[400],
        elevation: 7.0,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50))
          ),
        actions: <Widget>[
          PopupMenuButton(
            elevation: 7.0,
            icon: Icon(Icons.more_vert, color: Colors.white),
            tooltip: 'More',
            onSelected: (value) {
              choice = value.toString();
              choiceAction(choice);
            },
            itemBuilder: (_) => <PopupMenuItem<String>>[
              new PopupMenuItem<String>(
                  child: Row(
                      children: <Widget>[
                        Icon(Icons.assessment,color: Colors.black),
                        SizedBox(width: 15),
                        Text("Generate Bill"),
                      ]
                  ), value: 'Bill'),
              new PopupMenuItem<String>(
                  child: Row(
                      children: <Widget>[
                        Icon(Icons.perm_contact_calendar,color: Colors.black),
                        SizedBox(width: 35),
                        Text("About"),
                      ]
                  ), value: 'Us'),
            ],
          )],
        ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildTableCalendar(),
          const SizedBox(height: 8.0),
          const SizedBox(height: 8.0),
          Container(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: quanholder,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantity in Litres',
                      labelStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.blue))),
                    onChanged: (input) => updv = input,
                  ),
                  SizedBox(height: 30.0),
                  Container(
                      height: 40.0,
                      child: Material(
                        borderRadius: BorderRadius.circular(20.0),
                        shadowColor: Colors.deepOrange[600],
                        color: Colors.deepOrange[300],
                        elevation: 7.0,
                        child: InkWell(
                          onTap: () { store(); },
                          child: Center(
                            child: Text(
                              'Update Quantity',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat'),
                            ),
                          ),
                        ),
                      )),
                  SizedBox(height: 30.0),
                  Container(
                      height: 40.0,
                      child: Material(
                        borderRadius: BorderRadius.circular(20.0),
                        elevation: 7.0,
                        child: InkWell(
                          child: Center(
                            child: Text(
                              prsnt(),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat'),
                            ),
                          ),
                        ),
                      ),
                  ),
               ]),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.deepOrange[300],
        todayColor: Colors.deepOrange[100],
        markersColor: Colors.blue,
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle: TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
      initialCalendarFormat: CalendarFormat.week,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Week View',
        CalendarFormat.week: 'Month View',
      },
      onCalendarCreated: _onCalendarCreated,
    );
  }
  prsnt(){
    try{
      return "Present Quantity: "+_events[DateTime.parse(sel)][0].toString()+" L.";
    }
    catch(e){
      return "Present Quantity: 0 L.";
    }
  }
  store(){
    if(updv!='0' && updv!=null) {
      _upd = [double.parse(updv)];
      _events[DateTime.parse(sel)] = _upd;
      updv='0';
      storage();
    }
  }
  void choiceAction(String choice){
    if(choice == "Bill"){
      genbill();
    }else if(choice == "Us"){
      aboutd();
    }
  }
  aboutd() async{
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About'),
          content: Text('How to use?\n• Add Quantity by selecting date.\n'
              '• Generate bill by entering Rate, Month and Year in the more menu.\n\n'
              '♥ Dedicated to my Chacha.'),
          actions: <Widget>[
            FlatButton(
              onPressed: _rahulguptanitro,
              child: const Text('© RahulGuptaNitro'),
            ),
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  genbill() async{
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Generate Bill'),
          content: Container(child: new SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            //crossAxisAlignment: CrossAxisAlignment.start,
            //shrinkWrap: true,
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Milk Rate Per Litre',
                    labelStyle: TextStyle(
                        fontFamily: 'Montserrat',
                        //fontWeight: FontWeight.bold,
                        color: Colors.grey),
                    // hintText: '1000',
                    // hintStyle: ,
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(0xFF7A9BEE)))),
                onChanged: (input) => _rate = input,
              ),
            SizedBox(height: 10.0),
            FormField<String>(
              builder: (FormFieldState<String> state) {
                return InputDecorator(
                  decoration: InputDecoration(
                      labelStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                  isEmpty: _mon == 'Month',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _mon,
                      isDense: true,
                      hint: Text('Month'),
                      onChanged: (String newValue) {
                        setState(() {
                          _mon = newValue;
                          state.didChange(newValue);
                        });
                      },
                      items: monthsl.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 10.0),
            FormField<String>(
              builder: (FormFieldState<String> state) {
                return InputDecorator(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                  isEmpty: _yr == 'Year',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _yr,
                      isDense: true,
                      hint: Text('Year'),
                      onChanged: (String newValue) {
                        setState(() {
                          _yr = newValue;
                          state.didChange(newValue);
                        });
                      },
                      items: ['Year','2020',
                        '2021',
                        '2022',
                        '2023',
                        '2024',
                        '2025',
                        '2026',
                        '2027',
                        '2028',
                        '2029',
                        '2030'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
            ]),)),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              FlatButton(
                onPressed: () {
                  calc();
                },
                child: const Text('Generate Bill'),
              ),
            ],
          );
      },
    );
  }
  calc(){
    _selectedEvents=_events.keys.toList();
    int c=monthsl.indexOf(_mon);
    q=0.0;
    for(int k=0;k<_events.length;k++){
      if(int.parse(_selectedEvents[k].toString().substring(5,7))==c && _selectedEvents[k].toString().substring(0,4)==_yr){
        q=q+double.parse(_events[_selectedEvents[k]][0].toString());
      }
    }
    bil=q*double.parse(_rate);
    print(q);
    print(bil);
    calcbill();
  }
  calcbill() async{
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Your Bill'),
          content: Text(_mon.toString()+"  "+_yr.toString()+'\n\nMilk Purchased: '
              +q.toString()+" L.\nRate: ₹ "+_rate.toString()+" per L.\n\nTotal Bill: ₹ "
              +bil.toString()),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
                FocusScope.of(context).unfocus();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  _rahulguptanitro() async {
    const url = 'https://rahulguptanitro.github.io';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}