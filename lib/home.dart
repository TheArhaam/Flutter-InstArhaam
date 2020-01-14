//THIS FILE CONTAINS THE HOMEPAGE (THE PAGE DISPLAYED AFTER LOGIN)

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hello_flutter/userinformation.dart';
import 'package:hello_flutter/userlist.dart';
import 'package:hello_flutter/wallpapermanagement.dart';

//
class HomePage extends StatelessWidget {
  final UserDetails details; //this will store the LoggedInUsers details
  HomePage(
      this.details); //its called from LoginHome and the details are received after _signIn() is complete

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn googleSignIn =
        GoogleSignIn(); //this will be used to sign out

    return MaterialApp(
      //Theme for the entire HomePage
      theme: ThemeData(
        accentColor: Color(0xFF1b1b1b),
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

      //Scaffold contains the AppBar and Body
      home: Scaffold(
        //"resizeToAvoidBottomInset: false" prevents everything else from moving when keyboard comes up
        //opening the KeyBoard for the UploadImage dialog was causing an overflow for the Scaffold
        //so this was made false to prevent the scaffold elements from overflowing
        resizeToAvoidBottomInset: false,

        //AppBar contains InstArhaam logo and Text, Name of the LoggedInUser and SignOut IconButton
        appBar: AppBar(
          //Row for [InstArhaam logo] and [Column for InstArhaam Text, Line and LoggedInUsers name]
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.camera_alt),
              //Column for [InstArhaam Text], [Line] and [LoggedInUsers name]
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //InstArhaam text
                  Text(
                    '  InstArhaam',
                    style: TextStyle(
                        fontFamily:
                            'Billabong', //"Billabong" was added to pubspec.yaml and to the assets folder
                        fontSize: 25.0),
                  ),
                  //Used Container to make a LINE between InstArhaam Text and LoggedInUsers name
                  Container(
                    margin: EdgeInsets.only(bottom: 5),
                    height: 1.5,
                    color: Colors.white,
                    width: ('InstArhaam').length.toDouble() * 8,
                  ),
                  //LoggedInUsers name
                  Text(
                    '${details.userName}',
                    style: TextStyle(
                        fontFamily:
                            'BEBAS', //"BEBAS" was added to pubspec.yaml and to the assets folder
                        fontSize: 10.0),
                  )
                ],
              )
            ],
          ),

          actions: <Widget>[
            //IconButton for Signing Out
            IconButton(
              icon: Icon(
                FontAwesomeIcons.signOutAlt,
                color: Colors.white,
              ),
              onPressed: () {
                googleSignIn
                    .signOut(); //Pressing the IconButton calls signOut() which is a method of GoogleSignIn
                Navigator.pop(
                    context); //Navigator is used to pop the HomePage and go back to LoginHome
              },
            )
          ],
          centerTitle: true,
          //For opening the dialog to view a list of users
          leading: RaisedButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) => UserListPage(),
              );
            },
            child: Icon(Icons.contacts),
          ),
        ),

        //BODY CONTAINS THE COLUMN FOR [Row for View Users & Upload Image] and [Wallpaper cards]
        body: Column(
          children: <Widget>[
            // Column(
            // children: <Widget>[
            Management(details),
            // MainFeed(details),
            // ],
            // )
          ],
        ),
      ),
    );
  }
}
