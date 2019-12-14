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
  try{Response response = await post(
    'https://www.bonappetit.hu/kosarmuvelet',
    headers: {"Cookie":cookie},
    body: {
      'kosar': 'rendeles',
      'op': 'plusz',
      'db': '1',
      'etelid': '$foodId-${date.year}-$month-${date.day}',
      'Ar': '',
      'datum': '${date.year}-$month-${date.day}'
    }
  );
  snackText = response.statusCode == 200 ? "Sikeresen hozzáadva" : "Sikertelen";}
  catch(e){snackText="Sikertelen";}
  Scaffold.of(context).showSnackBar(SnackBar(content: Text(snackText),duration: Duration(seconds: 2),));
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
    if(alreadyOrdered && _tabController.index==2 && !_tabController.indexIsChanging){_bloc.refresh();};
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
      firstDate = DateTime.now().hour < 14 ? DateTime.now() : DateTime.now().add(Duration(days: 1));
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
                  validator: (value)=> value.toString().length < 4 && value.toString().length > 1 ? null : "Helytelen kód!",
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
          child: StreamBuilder(
            initialData: _lastData,
            stream: _bloc.stateController.stream,
            builder: (BuildContext context,AsyncSnapshot snapshot){
              _lastData = snapshot.data;
              return FoodList(snapshot.data);
            },
          )
        ),
        Align(
          child: FlatButton(
            child: Text("Rendelés"),
            onPressed: (){_bloc.refresh();},
          ),
        )
      ],
    );
  }  
}
class FoodList extends StatelessWidget{
  final List<List<String>> list;
  FoodList(this.list):super();
  @override
  Widget build(BuildContext context){
    if(list == null){return Text("üres");}
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (BuildContext context,int index){
        return Card(
          child: Text(list[index].join(" ")),
        );
      },
    );
  }
}