
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
Client client = Client();
ValueNotifier<int> activePage = ValueNotifier<int>(0);
String cookie;