import 'dart:io';
import 'dart:convert' as convert;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:zhihu_video/myNotify.dart';

class StorageModel with ChangeNotifier, DiagnosticableTreeMixin {
  //所有下载信息
  List<Video> _videoList = [];
  List<Video> get videoList => _videoList;


  void setVideoList(String url) async {
    _videoList.clear();
    try {
       var set = await ZhiHuVideo.search(url);
       set.forEach((element) => print (element.toString()));

       MyNotify().info("find ${set.length} videos");
       var list = set.toList();
       for (var i=0; i<list.length; i++) {
         var id = list[i];
         var video = await ZhiHuVideo.parse(id, path);
         if (video == null) {
           print("video $id get null");
           continue;
         }
         print(video.toString());
         _videoList.add(video);
       }

    } catch (e) {
      var s = "ERROR: ${e.toString()}";
      MyNotify().error(s);
    }

    _isGo = false;
    notifyListeners();
  }

  //点击开始
  bool _isGo = false;
  bool get isGo => _isGo;
  void setIsGo(bool b) {
    if (_isGo == b)  { return; }
    _isGo = b;
    notifyListeners();
  }

  //存储路径
  String get path => MyStorage().currentPath;
  void setPath(String s) async {
    _isGo = false;
    try {
      MyStorage().setCurrentPath(s);
      var info = "Set storage ok";
      print("Set storage ok: $s");
      MyNotify().info(info);
      //notifyListeners();
    } catch(e) {
      print("setPath error: ${e.toString()}");
    }
  }
}

class ZhiHuVideo {
  static RegExp reg0 = new RegExp(
    r"https://www.zhihu.com/?video/(\d{19})",
    caseSensitive: true,
    multiLine: true,
  );

  static Future<Set<String>> search(String url) async {
    http.Client client = http.Client();
    try {
      var rsp = await client.get(url);
      String body = rsp.body;
      var match = reg0.allMatches(body);
      if (match == null) {
        return Set();
      }
      return match.map((e) {
        print("get $e");
        return e.group(1);
      }).toSet();
    } finally{
      client.close();
    }
  }

  static Future<Video> parse(String vid, String path) async {
    http.Client client = http.Client();
    var url = "https://lens.zhihu.com/api/v4/videos/$vid";
    try{
      var rsp = await client.get(url);
      String body = rsp.body;
      print(body);
      var jsonD = convert.jsonDecode(body);
      if (jsonD["playlist"] == null) {
        throw("cat not get title");
      }

      var title = jsonD["title"]??"";
      var coverUrl = jsonD["cover_url"]??"";

      List<Info> infoList = [];
      ["LD", "SD", "HD"].forEach((type) {
        if (jsonD["playlist"][type] == null) {
          print("$vid: $type not exists.");
          return;
        }
        var size = jsonD["playlist"][type]["size"];
        var format = jsonD["playlist"][type]["format"];
        var url = jsonD["playlist"][type]["play_url"];
        var _name = "$vid.$type.$format";
        var _path = p.join(path, _name);
        infoList.add(Info(type:type, size:size, format:format, url:url, path:_path, name:_name));
      });
      return Video(id: vid, title: title, coverUrl: coverUrl, infoList: infoList);
    } catch(e) {
      print("$e");
      return null;
    } finally {
      client.close();
    }
  }
}

//下载数据
class Video {
  String id;
  String title;
  String coverUrl;
  List<Info> infoList;

  Video({this.id, this.title, this.coverUrl, this.infoList});

  String toString() {
    List<String> s = ["Video($id, $title, $coverUrl)"];
    infoList.forEach((value) => s.add(value.toString()));
    return s.toString();
  }
}

class Info {
  String type;
  int size;
  String url;
  String format;
  String path;
  String name;
  Info({this.type, this.size, this.format, this.url, this.path, this.name});

  String toStringDebug() => "$type, $size, $format, $path, $url";
  String toString() => "$type, $size, $format, $path";
}

//以后这块不这么写了，不需要用单例模式
class MyStorage {
  String _currentPath;
  String get currentPath => _currentPath;

  String _config;

  // 工厂模式
  factory MyStorage() =>_getInstance();
  static MyStorage get instance => _getInstance();
  static MyStorage _instance;

  MyStorage._();

  static MyStorage _getInstance() {
    if (_instance == null) {
      _instance = MyStorage._();
    }
    return _instance;
  }

  init() async {
    var appDocDir = await getApplicationDocumentsDirectory();
    print("appDocDir=${appDocDir.path}");

    //建目录
    if (FileSystemEntity.typeSync(appDocDir.path) == FileSystemEntityType.notFound) {
      await Directory(appDocDir.path).create(recursive: true).then(( Directory directory) {
        print("create ${directory.path} ok.");
      });
    }

    _config = p.join(appDocDir.path, "zhihu_video_config");

    //不存在给默认存储地址
    if (FileSystemEntity.typeSync(_config) == FileSystemEntityType.notFound) {
      _currentPath = appDocDir.path;
      return;
    }

    var file = File(_config);
    _currentPath = file.readAsStringSync();
  }

  setCurrentPath(String s) {
    //建目录
    if (FileSystemEntity.typeSync(s) == FileSystemEntityType.notFound) {
      Directory(s).createSync(recursive: true);
    }

    var file = File(_config);
    file.writeAsStringSync(s);
    _currentPath = s;

    return true;
  }

  String toString() {
    return "currentConfigPath: $_currentPath";
  }
}