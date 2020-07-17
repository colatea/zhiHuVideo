import 'package:flutter/material.dart';
import 'package:toast/toast.dart';


class MyNotify extends StatelessWidget {
  BuildContext _ctx;

  // 工厂模式
  factory MyNotify() => _getInstance();
  static MyNotify _instance;

  MyNotify._();

  static MyNotify _getInstance() {
    if (_instance == null) {
      _instance = MyNotify._();
    }
    return _instance;
  }


  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return Container();
  }

  info(String s){
    print(s);
    Toast.show(s, _ctx,
      duration: Toast.LENGTH_LONG,
      gravity: Toast.CENTER,
      textColor: Colors.white,
    );
  }

  error(String s){
    print(s);
    Toast.show(s, _ctx,
      duration: 5,
      gravity: Toast.CENTER,
      textColor: Colors.red,
    );
  }
}
