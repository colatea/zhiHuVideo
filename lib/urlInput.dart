import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zhihu_video/models/storageModel.dart';

class UrlInput extends StatelessWidget {
  BuildContext _ctx;
  StorageModel _model;
//  var _controller = TextEditingController(text: 'https://www.zhihu.com/question/404364365/answer/1324380669');
  var _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          flex: 70,
          child: _input(),
        ),
        Expanded(
          flex: 15,
          child: _clear(),
        ),
        Expanded(
          flex: 15,
          child: _action(),
        )
      ],
    );
  }

  Widget _input() {
    return TextField(
      controller: _controller,
      maxLines: 1,
      autofocus: false,
      textAlign: TextAlign.left,
      style: Theme.of(_ctx).textTheme.bodyText1,
      decoration: InputDecoration(hintText: ' Please enter the URL address of zhihu', hintStyle: Theme.of(_ctx).textTheme.bodyText2.copyWith(color: Colors.black45)),
      onTap: null,
//      keyboardType: TextInputType.text,
    );
  }

  Widget _clear() {
    return  Container(
        padding: EdgeInsets.only(left: 5, bottom: 5),
        height: double.maxFinite,
        child: FlatButton(
          color: Colors.blueGrey[100],
          hoverColor: Colors.blueGrey[200],
          child: Text("Clear", style: Theme.of(_ctx).textTheme.headline5.copyWith(fontWeight: FontWeight.w800)),
          onPressed: () {
            _controller.clear();
          },
    ));
  }



  Widget _action() {
    return Consumer<StorageModel>(
      builder: (_, m, __){
        _model = m;
        return  Container(
          padding: EdgeInsets.only(left: 5, bottom: 5),
          height: double.maxFinite,
          child: FlatButton(
            color: Colors.blueGrey[100],
            hoverColor: Colors.blueGrey[200],
            child: _buttonChild(m.isGo),
            onPressed: m.isGo ? null : _onPress,
        ));
      },
    );
  }

  Widget _buttonChild(bool isGo) {
    List<Widget> list = [];

    list.add( Text("Go", style: Theme.of(_ctx).textTheme.headline5.copyWith(
          fontWeight: FontWeight.w800,
          color: isGo ? Colors.blueGrey: Colors.deepOrange)),
    );

    if (isGo) {
      list.add( Container(
          margin: EdgeInsets.only(left: 10),
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        )
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: list
    );
  }

  void _onPress() {
    var url = _controller.text;
    print("action $url");
    _model.setIsGo(true);
    _model.setVideoList(url);
  }
}


