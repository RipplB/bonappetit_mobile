import 'package:flutter/material.dart';
import 'globals.dart';
import 'package:http/http.dart';
import 'foodlist_bloc.dart';

final _bloc = FoodlistBloc();
List<List<String>> _lastData;
bool alreadyOrdered = false;
void addToCart({BuildContext context,@required String foodId,@required DateTime date}) async{
  String snackText;
  final String month = date.month < 10 ? "0${date.month}" : "${date.month}";
  final String day = date.day < 10 ? "0${date.day}" : "${date.day}";
  try{Response response = await post(
    'https://www.bonappetit.hu/kosarmuvelet',
    headers: {"Cookie":cookie},
    body: {
      'kosar': 'rendeles',
      'op': 'plusz',
      'db': '1',
      'etelid': '$foodId-${date.year}-$month-$day',
      'Ar': '',
      'datum': '${date.year}-$month-$day'
    }
  );
  snackText = response.statusCode == 200 ? "Sikeresen hozzáadva" : "Sikertelen";}
  catch(e){snackText="Sikertelen";}
  Scaffold.of(context).showSnackBar(SnackBar(content: Text(snackText),duration: Duration(seconds: 1),));
  _bloc.refresh();
}
class Rendeles extends StatefulWidget {
  Rendeles({Key key}):super(key:key);
  @override
  _RendelesState createState() => _RendelesState();}

class _RendelesState extends State<Rendeles> with SingleTickerProviderStateMixin{
  TabController _tabController;
  final List<Widget> pages = [
    Center(child: Icon(Icons.cake,size:70.0),),
    CodeOrder(),
    Finalization(),
  ];
  final List<Widget> buttons = [
    Tab(text: 'Étlap',),
    Tab(text: 'Kódok',),
    Tab(text: 'Áttekintés',),
  ];
  @override
  void initState(){
    super.initState();
    _tabController = TabController(length: pages.length,vsync: this);
    _tabController.addListener(_tabbed);
  }
  @override
  void dispose(){
    _tabController.dispose();
    super.dispose();
  }
  void _tabbed(){
    FocusScope.of(context).unfocus();
    if(alreadyOrdered && _tabController.index==2 && !_tabController.indexIsChanging){_bloc.refresh();}
  }
  @override
  Widget build(BuildContext context){
    return Column(
      children: <Widget>[
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: pages
          ),
        ),
        Container(
          color: Color(0xFF620000),
          child: TabBar(
            controller: _tabController,
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
  final idField = TextEditingController();
  final codeOrderFormKey = GlobalKey<FormState>();
  _CodeOrderState(){
    if(DateTime.now().weekday<5){
      firstDate = DateTime.now().hour < 14 ? DateTime.now().add(Duration(days: 1)) : DateTime.now().add(Duration(days: 2));
    }else{
      firstDate = DateTime.now().add(Duration(days: 8-DateTime.now().weekday));
    }
    date = firstDate;
  }
  @override
  Widget build(BuildContext context){
    return Form(
      key: codeOrderFormKey,
      child: Column(
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
          ),
          Row(
            children: <Widget>[
              Expanded(child:Text("Írja be az étel kódját:")),
              Expanded(
                child:TextFormField(
                  validator: (value)=> value.toString().length < 4 && value.toString().length > 0 ? null : "Helytelen kód!",
                  controller: idField,
                )
              )
            ],
          ),
          Align(
            child: RaisedButton(
              child: Text("Hozzáadás"),
              onPressed: ()async{
                if (codeOrderFormKey.currentState.validate()) {
                  addToCart(context: context,foodId: idField.value.text,date: date);
                  alreadyOrdered = true;
                }
              }
            ),
          )
        ],
      )
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
    if(selectedDate!=null){date=selectedDate;}
    setState(()=>{});
  }
}
class Finalization extends StatefulWidget{
  State<StatefulWidget> createState()=> _FinalizationState();
}
class _FinalizationState extends State<Finalization>{
  @override
  Widget build(BuildContext context){
    return Column(
      children: <Widget>[
        Container(
          height: 60.0,
          color: Colors.white,
          child: Center(child: Text("Rendelés áttekintése"),),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: StreamBuilder(
              initialData: _lastData,
              stream: _bloc.stateController.stream,
              builder: (BuildContext context,AsyncSnapshot snapshot){
                _lastData = snapshot.data;
                if(_lastData == null){
                  return Text("Még nem rendelt semmit");
                }else{
                  return FoodList(snapshot.data);
                }
              },
            ),
          )
        ),
        Align(
          child: FlatButton(
            child: Text("Rendelés"),
            onPressed: ()async{
              try{
                Response response = await post(
                  'https://www.bonappetit.hu/rendeleskuldes',
                  body : {
                    'kartya':'futar',
                    'saveRendeles':1,
                    'fizetes':0
                  },
                  headers: {
                    "cookie":cookie
                  }
                );
                print(response.body);
              } catch(e){
                Scaffold.of(context).showSnackBar(SnackBar(content: Text("Sikertelen megrendelés"),duration: Duration(seconds: 2),));
              }
            },
          ),
        )
      ],
    );
  }  
}
class FoodList extends StatelessWidget{
  List<Widget> widgets = List<Widget>();
  List<DataColumn> columns;
  List<DataRow> rows = List<DataRow>();
  FoodList(List<List<String>> list):super(){
    for (List<String> line in list){
      if(line[0].contains(". hét összesen")){
        if(rows.length > 0){
          widgets.add(SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 10,
              columns: columns,
              rows: List.of(rows),
            ),
          ));
        }
        widgets.add(Text(
          line.join(" "),
          style: TextStyle(
            fontSize: 20.0
          ),
        ));
        continue;
      }
      if(line[0].contains(". hét")){
        widgets.add(Text(
          line.join(" "),
          style: TextStyle(
            fontSize: 20.0
          ),
        ));
        continue;
      }
      if(line[0].toLowerCase()=="nap"){
        rows.clear();
        columns = List<DataColumn>.generate(line.length, (int index)=>DataColumn(label: Text(line[index])));
        continue;
      }
      rows.add(DataRow(
        cells: List<DataCell>.generate(line.length, (int index)=>DataCell(Text(line[index]))) 
      ));
    }
  }
  @override
  Widget build(BuildContext context)=>Column(children: widgets,);
}