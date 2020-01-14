//THIS FILE CONTAINS THE MAIN METHOD THAT CALLS LoginPage()

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hello_flutter/login.dart';
import 'package:flutter/services.dart';

//THE MAIN FUNCTION IS EXECUTED FIRST
void main() {
  //runApp() is used to call the first page basically, this the point where the app starts it's execution
  runApp(LoginPage());
  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
}
