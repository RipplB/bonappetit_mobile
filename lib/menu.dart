import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'globals.dart';
import 'order.dart';

List<String> _title = ["Betöltés...","Rendelés","Lemondás","Korábbi rendelések","Információ","Profil","Kollégák"];
final _appBarKey = GlobalKey<_PermaAppBarState>();
Rendeles rendelesWidget = Rendeles();
List<Widget> widgets = [Container(),Rendeles(),Container(),Container(),Container(),Container(),Container()];
class Menu extends StatefulWidget{
  State<Menu> createState() => _MenuState();
}
class _MenuState extends State<Menu>{
  @override
  Widget build(BuildContext context){
    if (_title[0] == "Betöltés...") {
      _getName(cookie, 'https://www.bonappetit.hu/ebed-hazhozszallitas/rendeles');
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFFFE5BA),
        appBar: PermaAppBar(
          key: _appBarKey,
        ),
        drawer: Drawer(
          child: Container(  
            child: Column(
              children: createDrawerButtons(),
            ),
          color: Color(0xFF620000),
          ),
        ),
        body: ValueListenableBuilder(
          valueListenable: activePage,
          builder: (BuildContext context,int index, Widget child)=>widgets[index],
        ),
      ),
    );
  }
  void _getName(String cookie,String url) async{
    Future<Response> future = get(url,headers: {"cookie":cookie});
    future.then((Response response)=>{
      _appBarKey.currentState.setState(()=>{
        _title[0] = Utf8Decoder().convert(response.bodyBytes).substring(Utf8Decoder().convert(response.bodyBytes).indexOf("Üdv"),Utf8Decoder().convert(response.bodyBytes).indexOf("!",Utf8Decoder().convert(response.bodyBytes).indexOf("Üdv"))+1)
      })
    });
  }
}
class DrawerButton extends StatelessWidget{
  final int numOf;
  const DrawerButton({@required this.numOf});
  @override
  Widget build(BuildContext context){
    return OutlineButton(
      child: DrawerText(numOf!=0?_title[numOf]:"Főoldal"),
      borderSide: BorderSide(color: activePage.value==numOf?Colors.white:Colors.transparent,),
      onPressed: (){activePage.value = numOf;Navigator.pop(context);_appBarKey.currentState.refresh();},
    );
  }
}
class DrawerText extends StatelessWidget{
  final String text;
  DrawerText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 22.0
      ),
      textAlign: TextAlign.center,
    );
  }
}
class PermaAppBar extends StatefulWidget implements PreferredSizeWidget{
  PermaAppBar({Key key}):super(key:key);
  @override
  State<StatefulWidget> createState() {return _PermaAppBarState();}
  @override
  Size get preferredSize => Size.fromHeight(60.0);
}
class _PermaAppBarState extends State<PermaAppBar>{
  void refresh()=>setState((){});
  @override
  Widget build(BuildContext context){
    return AppBar(
      backgroundColor: Color(0xFF620000),
      title: Text(
        _title[activePage.value],
        style: TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 25.0
        )
      ),
    );
  }
}
List<Widget> createDrawerButtons(){
  List<Widget> list = new List<Widget>();
  list.add(Image.asset("assets/logo-bona-bottom.png"));
  for (var i = 0; i < _title.length; i++) {
    list.add(DrawerButton(numOf:i));
  }
  return list;
}