import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/storageModel.dart';
import 'urlInput.dart';
import 'saveInput.dart';
import 'downloadArea.dart';
import 'about.dart';
import 'myNotify.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  BuildContext _ctx;
  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return Scaffold(
      body: FutureBuilder(
        future: _homeInit(),
        builder: (_, snapShot) {
          if (snapShot.hasData) {
            print(snapShot.data);
            return _home();
          } else if (snapShot.hasError) {
            return _initError(snapShot.toString());
          }
          return _loading();
        },
      ),
      floatingActionButton: MyNotify(),
    );
  }
  Widget _loading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _initError(String s) {
    return Center(
      child: Text(s, style: Theme.of(_ctx).textTheme.bodyText1.copyWith(color: Colors.red)));
  }

  Widget _home() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<StorageModel>(create: (_) => StorageModel()),
      ],
      child: Container(
        padding: EdgeInsets.all(10),
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: UrlInput(),
            ),
            SizedBox(
              height: 50,
              child: SaveInput(),
            ),
            Expanded(
              child: DownloadArea(),
            ),
            Divider(),
            SizedBox(
              height: 30,
              child: About(),
            ),
          ],
    )));
  }

  Future<String> _homeInit() async {
    await MyStorage().init();
    return "MyStorage().init() complete~";
  }
}




