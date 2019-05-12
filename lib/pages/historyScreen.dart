import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;


class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => new _HistoryScreenState();
}


class _HistoryScreenState extends State<HistoryScreen> {
  // Device ID
  final String deviceId = 'PAC10GIX01001';

  // History data
  List _data;

  // Date
  List _date;
  
  @override
  void initState() {
    // implement initState
    super.initState();
    this._data = List();
    this._date = [ 
      ((new DateTime.now()).subtract(new Duration(days: 7))).toString().substring(0,11),
      new DateTime.now().toString().substring(0,11)
    ];
    this.requestData(deviceId);
  }

  Future<void> requestData(deviceId) async {
    print("calling");
    String startDate = _date[0];
    String endDate = _date[1];

    var response = await http.get(
      Uri.encodeFull("CALL SERVER ADDRESS")
    );
    print("history info");
    print(json.decode(response.body));

    if(this.mounted) {
      setState(() {
        _data = json.decode(response.body).toList();
        // print(_data[0].runtimeType);
      });
    }
  }

  Widget listHistory(int index) {
    if (index >= _data.length) {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.only(right:15.0, left: 15.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0), 
        decoration: 
          new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: new BorderRadius.circular(12.0),
            boxShadow: [
              new BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                // spreadRadius: 2
              ),]
          ),
        child: new Row(
          children: <Widget>[
            SizedBox(width: 20,),
            _data[index][4] == null? SizedBox(width: 90,)
              : Image.network(
                  _data[index][4],
                  fit: BoxFit.fill, width: 90.0, height: 85.0, 
                ),
            SizedBox(width: 10,),
            new Container(
              width: 220,
              height: 105,
              margin: const EdgeInsets.symmetric(vertical: 5.0),          
              decoration: new BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: new BorderRadius.circular(12.0),
              ), 
              child: Padding(padding: const EdgeInsets.only(top:10.0, left: 10.0),
                child: new Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text("Time: ", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(_data[index][0]),
                        Text(" "),
                        Text(_data[index][1].substring(0,8)),  
                      ]
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        Text("Status: ", style: TextStyle(fontWeight: FontWeight.bold)),
                        _data[index][2] == "n"? Text("Suspicous activity")
                          : Text("Package was stolen", style: TextStyle(color: Theme.of(context).textSelectionColor)),  
                      ]
                    ),
                    SizedBox(height: 5),  
                    RaisedButton(
                      child: Text("Video Link", style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        launch(_data[index][3]);
                      },
                      splashColor: Theme.of(context).accentColor,
                      elevation: 5.0,
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    ),
                  ]
                )
              )
            ),
          ],
        ),
      )
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45.0), // here the desired height
        child: AppBar(
          titleSpacing: 20,
          backgroundColor: Colors.white,
          title: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Date:", style: TextStyle(color: Colors.black, fontSize: 16),),
              SizedBox(width: 10,),
              Text(_date[0], style: TextStyle(color: Colors.black, fontSize: 16),),
              Text(" - ", style: TextStyle(color: Colors.black),),
              Text(_date[1], style: TextStyle(color: Colors.black, fontSize: 16),),
              SizedBox(width: 10,),
              new MaterialButton(
                minWidth: 5,
                textColor: Colors.white,
                color: Theme.of(context).buttonColor,
                onPressed: () async {
                  final List<DateTime> picked = await DateRagePicker.showDatePicker(
                      context: context,
                      initialFirstDate: new DateTime.now(),
                      initialLastDate: (new DateTime.now()).add(new Duration(days: 7)),
                      firstDate: new DateTime(2015),
                      lastDate: new DateTime(2020)
                  );
                  if (picked != null && picked.length == 2) {
                      setState(() {
                        _date[0] = picked[0].toString().substring(0,11);
                        _date[1] = picked[1].toString().substring(0,11);
                        this.requestData(deviceId);
                      });
                      print(picked);
                  }
                },
                child: Icon(Icons.calendar_today, size: 18,)
              )
            ]
          ),
        )
      )
      ,body: _data.length > 0? new ListView.builder(
        // itemCount: _data.length,
        itemBuilder: (BuildContext ctxt, int index) => listHistory(index)
      ): Center(child: Text("No Record", style: TextStyle(fontSize: 20),))
    );
  }
}
