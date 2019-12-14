import 'dart:async';
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as html;
import 'package:http/http.dart';
import 'globals.dart';

class FoodlistBloc{
  List<List<String>> _data  = List<List<String>>();
  final stateController = StreamController<List<List<String>>>.broadcast();
  void refresh() async{
    _data.clear();
    Response rp = await client.get("https://www.bonappetit.hu/kosar?het",headers: {
      "cookie":cookie
    });
    html.Element body = parse(Utf8Decoder().convert(rp.bodyBytes)).body;
    html.Element table = body.getElementsByClassName("artabla")[0];
    for(html.Element row in table.getElementsByTagName("tr")){
      List<String> texts = List<String>();
      for(html.Element column in row.getElementsByTagName("td")){
        if(column.text != null){
          texts.add(column.text.trim());
        }
      }
      _data.add(texts);
    }
    for (List<String>list in _data) {
      if(list.length >= 5){
        list.removeAt(4);
      }
      if(list.length >1){
        list.removeLast();
      }
    }
    stateController.add(_data);
  }
  void dispose(){
    stateController.close();
  }
}