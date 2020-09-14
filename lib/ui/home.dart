import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/utils.dart' as utils;

class Home extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _cityEntered;

  Future _NextScreen(BuildContext context) async {
    Map results = await Navigator.of(context)
        .push(new MaterialPageRoute<Map>(builder: (BuildContext context) {
      return ChangeCity();
    }));
    if (results != null && results.containsKey('enter')) {
      _cityEntered = results['enter'];
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Klimatic'),
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.menu), onPressed: (){_NextScreen(context);})
        ],
      ),
      body: new Stack(children: <Widget>[
        new Center(
          child: new Image.asset(
            'images/umbrella.png',
            height: 1200.0,
            fit: BoxFit.fill,
          ),
        ),
        new Container(
          alignment: Alignment.topRight,
          margin: const EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 0.0),
          child: new Text(
            '${_cityEntered == null ? utils.defaultCity : _cityEntered}',
            style: cityStyle(),
          ),
        ),
        new Container(
          alignment: Alignment.center,
          child: new Image.asset('images/light_rain.png'),
        ),
        new Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.fromLTRB(0.0, 380.0, 170.0, 0.0),
            child: updateWeatherTemp(_cityEntered)),
      ]),
    );
  }
}

Future<Map> getWeatherData(String city, String id) async {
  String apiUrl =
      'http://api.openweathermap.org/data/2.5/weather?q=$city&appid=$id&units=metric';
  http.Response response = await http.get(apiUrl);
  return json.decode(response.body);
}
Widget updateWeatherTemp(String city) {
  return new FutureBuilder(
      future:
          getWeatherData(city == null ? utils.defaultCity : city, utils.appId),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        //if (snapshot.hasData)
        Map content = snapshot.data;
        return new Container(
          child: new Column(
            children: <Widget>[
              new ListTile(
                title: new Text(
                  content['main']['temp'].toString(),
                  style: tempStyle(),
                ),
                subtitle: new ListTile(
                  title: new Text(
                    'Humidity: ${content['main']['humidity'].toString()}\n'
                    'Min: ${content['main']['temp_min'].toString()} C\n'
                    'Max: ${content['main']['temp_max'].toString()} C',
                    style: new TextStyle(
                        color: Colors.white70,
                        fontStyle: FontStyle.normal,
                        fontSize: 17.0),
                  ),
                ),
              )
            ],
          ),
        );
      });
}

class ChangeCity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _cityController = new TextEditingController();
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.red,
        title: new Text('Change City'),
        centerTitle: true,
      ),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset(
              'images/white_snow.png',
              width: 490,
             // height: 1200,
              fit: BoxFit.fill,
            ),
          ),
          new ListView(
            children: <Widget>[
              new ListTile(
                title: new TextField(
                  decoration: new InputDecoration(hintText: 'Enter City'),
                  controller: _cityController,
                  keyboardType: TextInputType.text,
                ),
              ),
              new ListTile(
                  title: new FlatButton(
                      onPressed: () {
                        Navigator.pop(context, {'enter': _cityController.text});
                      },
                      textColor: Colors.white70,
                      color: Colors.redAccent,
                      child: new Text('Get Weather')))
            ],
          )
        ],
      ),
    );
  }
}

TextStyle cityStyle() {
  return new TextStyle(
      color: Colors.white, fontSize: 30.0, fontStyle: FontStyle.italic);
}

TextStyle tempStyle() {
  return new TextStyle(
    color: Colors.white,
    fontSize: 60.0,
    fontWeight: FontWeight.bold,
  );
}
