import 'package:http/http.dart';

int activePage = 0;
String cookie;

Response _getResponse(String cookie,String url){
  Future<Response> future = get(url,headers: {"cookie":cookie});
  Response rp;
  future.then((Response response)=>{rp = response});
  return rp;
}