import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

class Menu extends StatefulWidget{
  State<Menu> createState() => _MenuState();
}
class _MenuState extends State<Menu>{
  String _name = "Betöltés...";
  @override
  Widget build(BuildContext context){
    final String cookie = ModalRoute.of(context).settings.arguments;
    _getName(cookie, 'https://www.bonappetit.hu/ebed-hazhozszallitas/rendeles');
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFFFE5BA),
        appBar: AppBar(
          backgroundColor: Color(0xFF620000),
          title: Text(
            _name,
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 25.0
            ),
          ),
        ),
        drawer: Drawer(),
      ),
    );
  }
  Response _getResponse(String cookie,String url){
    //Future response = _getFuture(cookie, url);
    Future<Response> future = get(url,headers: {"cookie":cookie});
    Response rp;
    future.then((Response response)=>{rp = response});
    return rp;
  }
  void _getName(String cookie,String url) async{
    Future<Response> future = get(url,headers: {"cookie":cookie});
    future.then((Response response)=>{
      setState(()=>{
        _name = Utf8Decoder().convert(response.bodyBytes).substring(Utf8Decoder().convert(response.bodyBytes).indexOf("Üdv"),Utf8Decoder().convert(response.bodyBytes).indexOf("!",Utf8Decoder().convert(response.bodyBytes).indexOf("Üdv"))+1)
      })
    });
  }
}