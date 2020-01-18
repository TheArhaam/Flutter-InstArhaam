//THIS FILE CONTAINS THE LOGIN PAGE AND THE IMPLEMENTATION FOR GOOGLE SIGN IN

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hello_flutter/userinformation.dart';
import 'package:hello_flutter/home.dart';

//CREATES LoginPageState
class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

//CONTAINS THE THEME OF THE PAGE AND CALL TO LoginHome
class LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //MATERIALAPP IS DEFINED HERE ITSELF TO PREVENT A FATAL EXCEPTION DURING NAVIGATION
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
              buttonColor: Color(0xFF1b1b1b),
              textTheme: ButtonTextTheme.primary),
          iconTheme: IconThemeData(color: Colors.white)),
      home: new LoginHome(),
    );
  }
}

//CONTAINS APPBAR, BODY AND IMPLEMENTATION OF _signIn()
class LoginHome extends StatelessWidget {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  //For Google Sign In
  Future<FirebaseUser> _signIn(BuildContext context) async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    FirebaseUser userDetails =
        await _firebaseAuth.signInWithCredential(credential);

    ProviderDetails providerInfo = ProviderDetails(userDetails.providerId);
    List<ProviderDetails> providerData = List<ProviderDetails>();
    providerData.add(providerInfo);

    //Stores the details of the LoggedInUser
    UserDetails details = UserDetails(
        userDetails.providerId,
        userDetails.displayName,
        userDetails.email,
        providerData,
        userDetails.photoUrl);

    var wallpaperdb = FirebaseDatabase.instance.reference().child('Wallpapers');

    //Checking if UserDetails are already present in the database
    var exists = false;

    await wallpaperdb.once().then((snapshot){
      Map users = snapshot.value;
      users.forEach((key,value){
        if(key.toString()==details.userEmail.substring(0, details.userEmail.length - 4)) {
          print('EXISTS');
          exists = true;
        }
      });
    });

    if (!exists) {
      print('DOES NOT EXIST');
      //Adding the LoggedInUser to the database
      wallpaperdb
          .child(details.userEmail.substring(0, details.userEmail.length - 4))
          .child('UserDetails')
          .set(details.getJson());
    }

    //Once LogIn is complete, LoggedInUser is navigated to MyApp()
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage(details)));
    return userDetails;
  }

  //CONTAINS THE SCAFFOLD WHICH INCLUDES THE BUTTON THAT CALLS _signIn()
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //Row for InstArhaam logo and text
          Container(
            padding: EdgeInsets.all(20),
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //InstArhaam logo (Just a camera)
                Icon(
                  Icons.camera_alt,
                  size: 70.0,
                ),
                //InstArhaam Text in Billabong font
                Text(
                  ' InstArhaam',
                  style: TextStyle(
                      fontFamily: 'Billabong',
                      fontSize: 70.0,
                      color: Colors.white),
                )
              ],
            ),
          ),

          //Row is used as a container for the RaisedButton, it keeps it wrapped to content and centralized
          Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //RaisedButton for GoogleSignIn
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0)),
                    child: Row(children: <Widget>[
                      //Google Icon from the 'font_awesome_flutter' package
                      Icon(FontAwesomeIcons.google, size: 20.0),
                      //Sign in Text
                      Text('  Sign in with Google'),
                    ]),
                    //Pressing the button calls _signIn()
                    onPressed: () => _signIn(context),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
