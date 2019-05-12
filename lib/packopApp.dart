import 'dart:io';
import 'package:flutter/material.dart';

import 'package:packop/pages/profileScreen.dart';
import 'package:packop/pages/historyScreen.dart';
import 'package:packop/pages/reportScreen.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

class PackopApp extends StatefulWidget {
  var cameras;
  PackopApp(this.cameras);

  @override
  _PackopAppState createState() => new _PackopAppState();
}

class _PackopAppState extends State<PackopApp>
    with SingleTickerProviderStateMixin {
  // Notification
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  
  // Tab Function
  TabController _tabController;
  ScrollController _scrollViewController;

  @override
  void initState() {
    // implement initState
    super.initState();
    // Notification
    firebaseCloudMessaging_Listeners();

    // Tab
    _tabController = new TabController(vsync: this, initialIndex: 0, length: 3);
    _scrollViewController = ScrollController();
    print(_tabController.index);
  }

  void firebaseCloudMessaging_Listeners() {
  if (Platform.isIOS) iOS_Permission();

  _firebaseMessaging.getToken().then((token){
    print(token);
  });

  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      _tabController.index = 1;
      new HistoryScreen();
    },
    onResume: (Map<String, dynamic> message) async {
      _tabController.index = 1;
      new HistoryScreen();
    },
    onLaunch: (Map<String, dynamic> message) async {
      _tabController.index = 1;
      new HistoryScreen();
    },
  );
}

void iOS_Permission() {
  _firebaseMessaging.requestNotificationPermissions(
      IosNotificationSettings(sound: true, badge: true, alert: true)
  );
  _firebaseMessaging.onIosSettingsRegistered
      .listen((IosNotificationSettings settings)
  {
    print("Settings registered: $settings");
  });
}

  @override
  void dispose() {
    // Tab
    _tabController.dispose();
    _scrollViewController.dispose();
    // implement initState
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body: NestedScrollView(
        controller: _scrollViewController,
        headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: new Text("PACKOP"),
              pinned: true,
              floating: false,
              forceElevated: boxIsScrolled,
              bottom: new TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: <Widget>[
                  new Tab(text: "Device", icon: Icon(Icons.portrait)),
                  new Tab(text: "History", icon: Icon(Icons.history)),
                  new Tab(text: "Report", icon: Icon(Icons.assignment)),
                ],
              ),
            )
          ];
        },
      body: new TabBarView(
        controller: _tabController,
        children: <Widget>[
          new ProfileScreen(),
          new HistoryScreen(),
          new ReportScreen(),
        ],
      ),
    )
    );
  }
}
