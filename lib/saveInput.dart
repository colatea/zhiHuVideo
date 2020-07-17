import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zhihu_video/myNotify.dart';
//import 'package:file_picker/file_picker.dart';  directory crash bug
import 'models/storageModel.dart';

class SaveInput extends StatelessWidget {
  BuildContext _ctx;
  StorageModel _model;
  TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return Consumer<StorageModel>(
      builder: (context, m, _){
        _model = m;
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              flex: 70,
              child: _input(),
            ),
            Expanded(
              flex: 30,
              child: _action(),
            )
          ],
        );
      }
    );
  }

  Widget _input() {
    _controller = TextEditingController(text: _model.path);
    return TextField(
      controller: _controller,
      maxLines: 1,
      autofocus: true,
      textAlign: TextAlign.left,
      style: Theme.of(_ctx).textTheme.bodyText1,
      decoration: InputDecoration(hintText: 'The path to the current storage', hintStyle: Theme.of(_ctx).textTheme.bodyText2.copyWith(color: Colors.black45)),
      onTap: null,
    );
  }

  Widget _action() {
    return Container(
        padding: EdgeInsets.only(left: 5, bottom: 5),
        height: double.maxFinite,
        child: FlatButton(
            color: Colors.blueGrey[100],
            hoverColor: Colors.blueGrey[200],
            child: Text("SetStorage", style: Theme.of(_ctx).textTheme.headline5.copyWith(fontWeight: FontWeight.w800, color: Colors.blue)),
            onPressed: () {
              var s = _controller.text.trim();
              if (s == "") { return; }
              _model.setPath(s);
            }
        ));
  }
}
