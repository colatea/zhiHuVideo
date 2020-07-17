import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'models/storageModel.dart';


class DownloadArea extends StatelessWidget {
  BuildContext _ctx;
  StorageModel _model;
  final ScrollController _scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return Container(
        width: double.maxFinite,
        color: Colors.white,
        //padding: EdgeInsets.symmetric(horizontal: 16.0),
        padding: EdgeInsets.only(top: 30),
        child: Consumer<StorageModel>(
          builder: (_, m, __) {
            _model = m;
            print("DownloadArea: ${_model.videoList.length}");
            return _downloadInfo();
          },
        )
    );
  }

  Widget _downloadInfo() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _model.videoList.map((video) => _Download(video)).toList(),
      ),
    );
  }

  Widget _Download(Video v) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
          boxShadow: [ BoxShadow(
          color: Colors.black12,  //底色,阴影颜色
//          offset: Offset(0, 0), //阴影位置,从什么位置开始
          blurRadius: 0.5,  // 阴影模糊层度
          spreadRadius: 0,  //阴影模糊大小
          ), ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _cover(v.coverUrl),
          SizedBox(width: 10),
          Expanded(
            child: Column( children: v.infoList.map((e) => Progress(e)).toList(), ),
          )
        ],
      )
    );
  }

  Widget _cover(String url) {
    print("cover: $url");
    return Container(
      height: 150,
      width: 100,
      child: url == "" ? Icon(Icons.error) : Image.network(url, fit: BoxFit.cover),
    );
  }


}

enum DlStatus{
  init,
  start,
  pause,
  done,
  error
}


class Progress extends StatefulWidget {
  Info info;

  Progress(this.info);

  @override
  _ProgressState createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  DlStatus _status;
  double _percentage;
  Info _v;
  String _sizeM;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _v = widget.info;
    _status = DlStatus.init;
    _percentage = 0;
    _sizeM = "${(_v.size/1048576).toStringAsFixed(2)}M";
  }

  void setPercentage(int received) {
    setState(() {
      _percentage = received / _v.size;
    });
  }

  void setStatus(DlStatus i) {
    setState(() {
      _status = i;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${_v.name}  $_sizeM"),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 70,
              child: Container( child: LinearProgressIndicator( minHeight: 5, value: _percentage, ), ),
            ),
            Expanded(
              flex: 5,
              child: Container(),
            ),
            Expanded(
              flex: 15,
              child: Text("${(_percentage*100).toStringAsFixed(2)}%"),
            ),
            Expanded(
              flex: 10,
              child: _button(),
            )
          ]),
      ],
    );
  }



  Widget _button() {
    IconData iconData;
    Color color;
    switch (_status) {
      case DlStatus.init: {
        print(2222);
        color = Colors.blue;
        iconData = Icons.play_arrow;
      }
      break;

      case DlStatus.pause: {}
      break;

      case DlStatus.start: {
        color = Colors.blue;
        iconData = Icons.pause;
      }
      break;

      case DlStatus.done: {
        color = Colors.green;
        iconData = Icons.check;
      }
      break;

      case DlStatus.error: {
        color = Colors.red;
        iconData = Icons.close;
      }
      break;

    }

    return IconButton(
      icon: Icon(iconData, color: color,),
      onPressed: DlStatus.init == _status ? _onPress : null,
    );
  }


  _onPress() async {
    print("start");
    setStatus(DlStatus.start);
    HttpClient client = HttpClient();
    var _downloadData = List<int>();
    var fileSave = File(_v.path);

    client.getUrl(Uri.parse(_v.url)).then((
        HttpClientRequest request) => request.close()
    ).then((e) => e.listen(
      (d) {
//        print("${d.length}, ${_downloadData.length}");
        if (d.length > 1) {
          setPercentage(_downloadData.length);
        }
        _downloadData.addAll(d);
      },
      onDone: () {
        fileSave.writeAsBytesSync(_downloadData);
        setPercentage(_downloadData.length);
        setStatus(DlStatus.done);
      },
      onError: (e) {
        print(e.toString());
        setStatus(DlStatus.error);
      }
    ));
  }
}

