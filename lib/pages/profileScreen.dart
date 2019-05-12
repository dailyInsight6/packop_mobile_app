import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:packop/assetView.dart';


class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => new _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {
  // Image Function
  List<Asset> images = List<Asset>();

  // Device ID
  final String deviceId = '';
  String _address = "";
  String _names = "";
  String _number = "";

  // New member registration
  static final TextEditingController _nameController = new TextEditingController();
  FocusNode _focusNodeName = new FocusNode();
  String _newName = "";

  // Progress indicator
  bool _isLoading = false;

  @override
  void initState() {
    // implement initState
    super.initState();
    this.requestData(deviceId);
  }

  Future<void> requestData(deviceId) async {
    var response = await http.get(
      Uri.encodeFull("CALL SERVER ADDRESS")
    );
    print("device info");
    print(json.decode(response.body));
    
    if (this.mounted){
      setState(() {
        List result = json.decode(response.body);
        _address = result[0][2];
        _number = result.length.toString();
        for (var i = 0; i < result.length; i++) {
          _names = _names + result[i][0] + " " + result[i][1];
          if (i < result.length-1){
            _names = _names + ", ";
          }
        }
      });
    }
  }
  
  void showMessage(String msg){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text(msg),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Close", style: TextStyle(color: Colors.black87)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
  }

  Future<void> upload() async {

    if (_newName.isEmpty) {
      showMessage("New member's name is required.");
    }
    else if (_newName.split(" ").length < 2) {
      showMessage("First and last names are required.");
    }
    else if (images.length < 4) {
      showMessage("Please select 4 photos of your front face.");
    } else {
      String name = _newName; // Person Name
      String personId = ""; // Person Id
      int count = 1;

      print("This is a start");
      var url = "CALL SERVER ADDRESS";
      Map data = {
        'deviceId': deviceId,
        'address': _address,
      };

      //encode Map to JSON
      var body = json.encode(data);

      var response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: body
      );
      print("${response.statusCode}");
      print("${response.body}");

      personId = response.body;
      if (response.statusCode == 200 && this.mounted) {
        setState(() {
          _isLoading = true;
        });

        var messageShow = false;
        
        // 2. Add faces to a created person above
        for (Asset asset in images) {
          String url = "CALL SERVER ADDRESS"; // Server
          Uri uri = Uri.parse(url);

          // create multipart request
          http.MultipartRequest request = http.MultipartRequest("POST", uri);

          ByteData byteData = await asset.requestOriginal();
          List<int> imageData = byteData.buffer.asUint8List();

          http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
            'photo',
            imageData,
            filename: name + '.jpg',
            contentType: MediaType("image", "jpg"),
          );

          // add file to multipart
          request.files.add(multipartFile);

          // send
          http.StreamedResponse response = await request.send();

          asset.releaseOriginal();
          print(response.statusCode);
          response.stream.transform(utf8.decoder).listen((value) {
            if (count == 5) {
              if (value == "confirmed"){
                showMessage("[Recognized] Completed new registration");
              } else {
                if(!messageShow){
                  showMessage("[Not Recognized] Please add more photos");
                  messageShow = true;
                }
              }
              setState(() {
                _isLoading = false;
              });
            }
          });
          count++;
        }
        _names = "";
        requestData(deviceId);
        _nameController.clear();
      } else {
        print("No personId");
      }
    }  
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return ViewImages(index, asset, key: UniqueKey(),);
      }),
    );
  }

  Future<void> loadAssets() async {
    setState(() {
      images = List<Asset>();
    });

    List<Asset> resultList;
    String error;

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 4,
        enableCamera: false,
      );
    } on PlatformException catch (e) {
      error = e.message;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
    });
  }

  @override
  Widget build(BuildContext context) {
    var profileInfo = new Container (   
      child: new Column (
        children: [
          Row (
            children: [
              Text(
                "Device Information",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0
                ),
              )
            ]
          ),
          SizedBox(height: 15.0),
          Row (
            children : [
              Column (
                children: [
                  Image.asset(
                    'images/packop.jpg',
                    width: 100.0,
                    height:100.0,
                    fit: BoxFit.fill,
                  ),
                ]
              ),
              SizedBox(width: 30.0),
              Flexible(
                child: Column (
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row (
                      children: <Widget>[
                        Text(
                          "Device ID  ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                            )
                        ),
                        Text("$deviceId"),
                      ]
                    ),
                    SizedBox(height: 10.0,),
                    Text(
                      "Address",
                      style: TextStyle(
                              fontWeight: FontWeight.bold
                            )
                    ),
                    SizedBox(height: 5.0,),
                    Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 1.0, // gap between adjacent chips
                      runSpacing: 7.0, // gap between lines
                      children: <Widget>[
                        Text(_address)
                      ],
                    ),
                    SizedBox(height: 10.0,),
                    Row (
                      children: <Widget>[
                        Text(
                          "Member ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                            )
                        ),
                        Text("$_number people"),
                      ]
                    ),
                    SizedBox(height: 5.0,),
                    Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 1.0, // gap between adjacent chips
                      runSpacing: 7.0, // gap between lines
                      children: <Widget>[
                        Text(_names)
                      ],
                    )
                  ]
                )
              )
            ]
          )
        ]
      ) 
    );

    var memberReg = new Container ( 
      alignment: Alignment.centerLeft,
      child: new Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "New Member Registration",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0
            ),
          ),
          new TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  labelText: 'Full Name *',
                  hintText: 'First name & Last name'
                ),
                controller: _nameController,
                focusNode: _focusNodeName,
                validator: (value) {
                  print(value);
                },
                onFieldSubmitted: (value) {
                  _newName = value;
                }
              ),
          SizedBox(height: 10.0),
          Text (
            "1. Select 4 photos of new member's front face",
            style: TextStyle(
              fontSize: 15.8
            ),
          ),
          SizedBox(height: 3.0),
          Text (
            "   (Note: Photos have only one person's face)",
            style: TextStyle(
              fontSize: 13.0
            ),
          ),
          SizedBox(height: 10.0),
          Text (
            "2. Click the add button",
            style: TextStyle(
              fontSize: 15.8
            ),
          )
        ]
      )
    );
    
    return new Container(
        padding: new EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
        width: MediaQuery.of(context).size.width*0.7,
        child: new Scaffold(   
          resizeToAvoidBottomPadding: false,
          body: ModalProgressHUD(
              child: new Column( 
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  profileInfo,
                  SizedBox(height: 30.0),
                  memberReg,
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        child: Text("Open Gallery", style: TextStyle(color: Colors.white)),
                        onPressed: loadAssets,
                        splashColor: Theme.of(context).accentColor,
                        elevation: 3.0,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))
                      ),
                      RaisedButton(
                        child: Text("Add", style: TextStyle(color: Colors.white)),
                        // color: Theme.of(context).accentColor,
                        onPressed: upload,
                        splashColor: Theme.of(context).accentColor,
                        elevation: 3.0,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))
                      )
                    ]
                  ),
                  Expanded(
                    child: buildGridView(),
                  )
                ]
              ),
              inAsyncCall: _isLoading,
              opacity: 0,
              color: Theme.of(context).buttonColor,
          )
        )
    );  
  }
}

