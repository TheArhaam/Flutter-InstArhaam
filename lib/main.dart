import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hello_flutter/login.dart';
import 'wallpapermanagement.dart';

void main() {
  runApp(
      LoginPage()); //Method provided to run the app, takes a widget as an argument, preferrably using the container widget i guess
}

class MyApp extends StatelessWidget {
  final UserDetails details;
  MyApp(this.details);
  @override
  Widget build(BuildContext context) {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF1b1b1b),
        cardColor: Color(0xFF212121),
        canvasColor: Color(0xFF484848),
        buttonColor: Colors.white,
        cardTheme: CardTheme(
          margin: EdgeInsets.all(10.0),
          elevation: 15.0,
        ),
        buttonTheme: ButtonThemeData(
            buttonColor: Color(0xFF1b1b1b), textTheme: ButtonTextTheme.primary),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.camera_alt),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '  InstArhaam',
                    style: TextStyle(fontFamily: 'Billabong', fontSize: 25.0),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 5),
                    height: 1.5,
                    color: Colors.white,
                    width: ('InstArhaam').length.toDouble() * 8,
                  ),
                  Text(
                    '${details.userName}',
                    style: TextStyle(fontFamily: 'BEBAS', fontSize: 10.0),
                  )
                ],
              )
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                FontAwesomeIcons.signOutAlt,
                color: Colors.white,
              ),
              onPressed: () {
                googleSignIn.signOut();
                Navigator.pop(context);
              },
            )
          ],
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[AddWallpaper(details)],
        ),
      ),
    );
  }
}
