import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert'; 
import 'package:intl/intl.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => new _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {

  // Device ID
  final String deviceId = 'PAC10GIX01001';

  // DATA VARIABLES
  String _warningCnt = '';
  String _protectionRate = '';
  String _safeDay = '';

  List<List<double>> _charts = [[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]];
  List<List<String>> _chartDays = [[],[]];

  static final List<String> chartDropdownItems = [ 'Next week', '2 weeks later'];
  String actualDropdown = chartDropdownItems[0];
  int actualChart = 0;


  Future<void> requestData(deviceId) async {
    var response = await http.get(
      Uri.encodeFull("CALL SERVER ADDRESS")
    );
    print("REPORT info");
    print(json.decode(response.body));
    
    if (this.mounted){
      setState(() {
        List result = json.decode(response.body);

        _warningCnt = result[0][3].toString();
        _protectionRate = result[0][4].toString() + "%";
        
        double smallProb = 1.0;
        int index = 0;
        int cnt = 0;
        int chartIndex = 0;
        List day;

        for (var i = 1; i < result.length; i++) {
          if(result[i][1] < smallProb) {
            smallProb = result[i][1];
            index = i;
          }
          day = result[i][0].split("-");
          
          _charts[cnt][chartIndex] =1-result[i][1];
          _chartDays[cnt].add(day[2]);
          chartIndex ++;

          if(i == 7){
            cnt ++;
            chartIndex = 0;
          }
        }

        List safeDay = result[index][0].split("-");
        _safeDay =  new DateFormat.MMMMd("en_US").format(DateTime(int.parse(safeDay[0]),int.parse(safeDay[1]),int.parse(safeDay[2]))) + "  " +result[index][2];
        
      });
    }
  }

  @override
  void initState() {
    // implement initState
    super.initState();
    this.requestData(deviceId);
  }

  Widget _buildTile(Widget child, {Function() onTap}) {
    return Material(
      elevation: 14.0,
      borderRadius: BorderRadius.circular(12.0),
      shadowColor: Theme.of(context).accentColor,
      child: child
    );
  }

  List<Widget> _axisLabel(int index) {
    List<Widget> list = new List();
    
    for(int i = 0; i < _chartDays[index].length; i++){
      list.add(new Text(_chartDays[index][i], style: TextStyle(fontSize: 14),));
      if(i < _chartDays[index].length -1 ){
        list.add(new SizedBox(width: 25,));
      }
    }
    return list;
  }

  Widget buildGridView() {
    return StaggeredGridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: <Widget>[
          _buildTile(
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column
              (
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>
                [
                  Material
                  (
                    color: Colors.red,
                    shape: CircleBorder(),
                    child: Padding
                    (
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(Icons.warning, color: Colors.white, size: 30.0),
                    )
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 16.0)),
                  Text(_warningCnt, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 24.0)),
                  Text('times warning', style: TextStyle(color: Colors.black45)),
                ]
              ),
            ),
          ),
          _buildTile(
            Padding
            (
              padding: const EdgeInsets.all(24.0),
              child: Column
              (
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>
                [
                  Material
                  (
                    color: Colors.amber,
                    shape: CircleBorder(),
                    child: Padding
                    (
                      padding: EdgeInsets.all(16.0),
                      child: Icon(Icons.security, color: Colors.white, size: 30.0),
                    )
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 16.0)),
                  Text(_protectionRate, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 24.0)),
                  Text('protection rate', style: TextStyle(color: Colors.black45)),
                ]
              ),
            ),
          ),
          _buildTile(
            Padding
            (
              padding: const EdgeInsets.all(24.0),
              child: Row
              (
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>
                [
                  Column
                  (
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>
                    [
                      Text('The Safest Day in 2 weeks', style: TextStyle(color: Colors.teal[700])),
                      Text(_safeDay, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 24.0))
                    ],
                  ),
                  Material
                  (
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(24.0),
                    child: Center
                    (
                      child: Padding
                      (
                        padding: EdgeInsets.all(12.0),
                        child: Icon(Icons.insert_emoticon, color: Colors.white, size: 40.0),
                      )
                    )
                  )
                ]
              ),
            ),            
          ),
          _buildTile(
            Padding
            (
              padding: const EdgeInsets.all(24.0),
              child: Column
              (
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>
                [
                  Row
                  (
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>
                    [
                      Column
                      (
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>
                        [
                          Text('Package Safe', style: TextStyle(color: Colors.teal[700])),
                          Text('Prediction', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 24.0)),
                        ],
                      ),
                      DropdownButton
                      (
                        isDense: true,
                        value: actualDropdown,
                        onChanged: (String value) => setState(()
                        {
                          actualDropdown = value;
                          actualChart = chartDropdownItems.indexOf(value); // Refresh the chart
                        }),
                        items: chartDropdownItems.map((String title)
                        {
                          return DropdownMenuItem
                          (
                            value: title,
                            child: Text(title, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14.0)),
                          );
                        }).toList()
                      )
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 20.0)),
                  _charts[actualChart][0] == 0.0? new Center(child: Text("Loading")):Sparkline
                  (
                    data: _charts[actualChart],
                    lineWidth: 5.0,
                    lineColor: Colors.teal[700],
                    pointsMode: PointsMode.all,
                    pointSize: 8.0,
                    pointColor: Colors.orange,
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 20.0)),
                  Row(children: _axisLabel(actualChart))
                ],
              )
            ),
          )
        ],
        staggeredTiles: [          
          StaggeredTile.extent(1, 180.0),
          StaggeredTile.extent(1, 180.0),
          StaggeredTile.extent(2, 110.0),
          StaggeredTile.extent(2, 255.0),
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: new EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
      child: buildGridView()
    );
  }
}
