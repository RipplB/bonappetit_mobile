import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget{
  @override
  Widget build(BuildContext context){
    return Container(
      child: Center(
        child: Text(
          "Bonappetit ételrendelés",
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 32.0,
          ),
        ),
      ),
      color: Color(0xFF620000),
    );
  }
  @override
  Size get preferredSize => Size.fromHeight(100.0);
}