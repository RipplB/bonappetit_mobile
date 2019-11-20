import 'package:flutter/material.dart';

class Rendeles extends StatelessWidget{
  final pages = <Widget>[
    Center(child: Icon(Icons.cake,size:70.0),),
    Center(child: Icon(Icons.calendar_view_day,size:70.0),),
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