import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'header.dart';
import 'globals.dart';

final _indicatorKey = GlobalKey<_LoginIndicatorState>();
final _formKey = GlobalKey<FormState>();
class LoginPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return SafeArea(
      child:Scaffold(
        appBar:Header(),
        backgroundColor: Color(0xFFFFE5BA),
        body: Padding(
          child:Column(
            children: <Widget>[
              Divider(height: 30,color: Color(0x00FFFFFF),),
              Text(
                "Kérem, írja be a bejelentkezési adatait!",
                textAlign:TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold
                ),
              ),
              Divider(thickness: 3 ,indent: 20,endIndent: 20,),
              LoginForm(),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 0,horizontal: 10),
        )
      )
    );
  }
}
class LoginForm extends StatelessWidget{
  final TextEditingController _username = TextEditingController(),_password = TextEditingController();
  @override
  Widget build(BuildContext context){
    return Form(
      key: _formKey,
      child:Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child:Text(
                  "Azonosító/e-mail:",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                )
              ),
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _username,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Írja be az e-mail címét!';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "pelda@mail.com",
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child:Text(
                  "Jelszó:",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                )
              ),
              Expanded(
                child: TextFormField(
                  obscureText: true,
                  autocorrect: false,
                  controller: _password,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Írja be a jelszavát!';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "jelszó",
                  ),
                )
              ),
            ],
          ),
          Divider(color: Color(0x00FFFFFFF),height: 10,),
          Align(
            child: RaisedButton(
              child: Text(
                "BELÉPÉS",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Color(0xFFFFFFFF)
                ),
              ),
              onPressed: ()=>{
                if(_formKey.currentState.validate()){
                  _indicatorKey.currentState.start(),
                  _tryLogin(_username.value.text, _password.value.text,context)
                }
              },
              color: Color(0xFF620000),
              splashColor: Color(0x99DD0000),
              highlightColor: Color(0x99DD0000),
            ),
            alignment: Alignment(0.8,0),
          ),
          Divider(
            height: 25,
            color: Color(0x00FFFFFF),
          ),
          LoginIndicator(key: _indicatorKey,)
        ],
      )
    );
  }
}
class _LoginIndicatorState extends State<LoginIndicator>{
  Widget _theWidget;
  @override
    void initState() {
      empty();
      super.initState();
    }
  @override
  Widget build(BuildContext context) {
    return _theWidget;
  }
  void start(){
    setState(() {
     _theWidget = CircularProgressIndicator(
     );
   });
  }
  void failed(){
    setState(() {
      _theWidget = Column(
        children: <Widget>[
          Center(child:Icon(Icons.error,size: 70,color: Color(0xFFFF1B1B),)),
          Text(
            "Belépés sikertelen! Kérem ellenőrizze a beírt adatokat!",
            overflow: TextOverflow.clip,
            maxLines: 10,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFFFF0000),
            ),
          )
        ],
      );
    });
  }
  void empty(){
    setState(() {
          _theWidget = Container(width: 0.0,height: 0.0,);
    });
  }
  void simpleText(String data){
    setState(() {
          _theWidget = Text(data);
        });
  }
}
class LoginIndicator extends StatefulWidget{
  final Key key;
  LoginIndicator({this.key});
  @override
  State<LoginIndicator> createState() => _LoginIndicatorState();
}
void _tryLogin(String email,String password, BuildContext context) async{
  Response response = await client.post(
    'https://www.bonappetit.hu/ebed-hazhozszallitas/fooldal',
    body:{
      "fooduser" : email,
      "foodpass" : password,
      "foodlogin" : "Belépés"
    },
  );
  cookie = response.headers["set-cookie"];
  cookie = cookie.substring(0,cookie.indexOf(';'));
  response = await client.get('https://www.bonappetit.hu/ebed-hazhozszallitas/rendeles',headers: {"cookie":cookie});
  String html = Utf8Decoder().convert(response.bodyBytes);
  try{
    html.substring(html.indexOf("Üdv")+4,html.indexOf("!",html.indexOf("Üdv")));
    _indicatorKey.currentState.empty();
    _formKey.currentState.reset();
    Navigator.pushNamed(context, 'menu');
  }
  catch(e){
    _indicatorKey.currentState.failed();
  }
}