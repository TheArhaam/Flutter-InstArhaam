import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hello_flutter/main.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
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
              buttonColor: Color(0xFF1b1b1b),
              textTheme: ButtonTextTheme.primary),
          iconTheme: IconThemeData(color: Colors.white)),
      home: new LoginHome(),
    );
  }
}

class LoginHome extends StatelessWidget {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
    UserDetails details = UserDetails(
        userDetails.providerId,
        userDetails.displayName,
        userDetails.email,
        providerData,
        userDetails.photoUrl);

    var wallpaperdb = FirebaseDatabase.instance.reference().child('Wallpapers');
    // wallpaperdb
    //     .child(details.userEmail.substring(0, details.userEmail.length - 4))
    //     .child('display picture')
    //     .set(details.photoUrl);
    wallpaperdb
        .child(details.userEmail.substring(0, details.userEmail.length - 4))
        .child('UserDetails')
        .set(details.getJson());
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MyApp(details)));
    return userDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.camera_alt,
                size: 70.0,
              ),
              Text(
                ' InstArhaam',
                style: TextStyle(
                    fontFamily: 'Billabong',
                    fontSize: 70.0,
                    color: Colors.white),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                child: Row(children: <Widget>[
                  Icon(FontAwesomeIcons.google, size: 20.0),
                  Text('  Sign in with Google'),
                ]),
                onPressed: () => _signIn(context),
              )
            ],
          )
        ],
      ),
    );
  }
}

class UserDetails {
  final String providerDetails;
  final String userName;
  final String userEmail;
  final String photoUrl;
  final List<ProviderDetails> providerData;
  UserDetails(this.providerDetails, this.userName, this.userEmail,
      this.providerData, this.photoUrl);
  getJson() {
    return {
      'userName': '${userName}',
      'userEmail': '${userEmail}',
      'photoUrl': '${photoUrl}',
    };
  }
}

class UserDisplayDetails {
  final String dpUrl;
  final String userEmail;
  final String userName;
  UserDisplayDetails(this.dpUrl, this.userEmail,this.userName);
}

class ProviderDetails {
  final String providerDetails;
  ProviderDetails(this.providerDetails);
}
