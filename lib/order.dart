import 'package:flutter/material.dart';

class Rendeles extends StatelessWidget{
  final pages = <Widget>[
    Center(child: Icon(Icons.cake,size:70.0),),
    CodeOrder(),
    Center(child: Icon(Icons.cake,size:70.0),),
  ];
  final buttons = <Widget>[
    Tab(text: 'Étlap',),
    Tab(text: 'Kódok',),
    Tab(text: 'Áttekintés',),
  ];
  Rendeles({Key key}):super(key:key);
  @override
  Widget build(BuildContext context){
    return DefaultTabController(
      length: pages.length,
      child: Column(
        children: <Widget>[
          Expanded(
            child: TabBarView(
              children: pages
            ),
          ),
          Container(
            color: Color(0xFF620000),
            child: TabBar(
              tabs: buttons,
              indicatorColor: Colors.white,
              indicatorWeight: 4.5,
              labelPadding: EdgeInsets.symmetric(horizontal: 0),
              labelStyle: TextStyle(
                fontSize: 20.0
              ),
            )
          )
        ],
      ),
    );
  }
}
class CodeOrder extends StatefulWidget{
  @override
    State<StatefulWidget> createState() {
      return _CodeOrderState();
    }
}
class _CodeOrderState extends State<CodeOrder>{
  DateTime date;
  DateTime firstDate;
  _CodeOrderState(){
    if(DateTime.now().weekday<5){
      firstDate = DateTime.now().hour < 14 ? DateTime.now() : DateTime.now().add(Duration(days: 1));
    }else{
      firstDate = DateTime.now().add(Duration(days: 8-DateTime.now().weekday));
    }
    date = firstDate;
  }
  @override
  Widget build(BuildContext context){
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 20.0),
          padding: EdgeInsets.all(25.0),
          decoration: BoxDecoration(
            color: Color(0xBBFFFFFF),
            borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
          child: Text(
            "Rendelés kód alapján",
            style:TextStyle(
              fontSize: 30.0,
            ),
          )
        ),
        Row(
          children: <Widget>[
            Text("Válasszon dátumot:"),
            OutlineButton(
              child: Text("${date.year}-${date.month}-${date.day}"),
              onPressed: ()=>setDate(),
            )
          ],
        )
      ],
    );
  }
  void setDate() async{
    DateTime selectedDate = await showDatePicker(
      context: context,
      firstDate: firstDate.subtract(Duration(days: 1)),
      initialDate: date,
      lastDate: firstDate.add(Duration(days: 8-firstDate.weekday+13)),
      selectableDayPredicate: (selected)=> selected.weekday != 7,
      locale: Locale("hu")
    );
    if(selectedDate!=null){date=selectedDate;};
    setState(()=>{});
  }
}