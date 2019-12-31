// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:hello_flutter/userinformation.dart';
// import 'package:hello_flutter/wallpaper.dart';

// class MainFeed extends StatefulWidget {
//   final UserDetails details;

//   const MainFeed(this.details);

//   @override
//   State<StatefulWidget> createState() {
//     return MainFeedState(details);
//   }
// }

// class MainFeedState extends State<MainFeed> {
//   List<UserDisplayDetails> userlist = List();
//   final UserDetails details;
//   int count = 0;
//   List<Wallpaper> wallpaperlist = List();
//   String tempurl = '',
//       temptxt = '',
//       tempowner = '',
//       tempdpurl = '',
//       tempemail = '',
//       tempuname = '';
//   bool templiked = false;
//   var wallpaperdb = FirebaseDatabase.instance.reference().child('Wallpapers');

//   MainFeedState(this.details) {
//     initWallpapers();
//     initUsers();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WallpaperListWidget(wallpaperlist, details);
//   }

// //For initializing the wallpaper list from the Database
//   initWallpapers() {
//     String
//         currentUser; //Cut email of the user whose images are currently being added to the wallpaperlist

//     wallpaperdb.once().then((ds) {
//       Map emailds = ds.value; //DataSnapchat at the Cut email
//       emailds.forEach((key, value) {
//         currentUser = key.toString(); //Setting the current user

//         Map imagesds =
//             value; //DataSnapshot at the Images child of the current user
//         imagesds.forEach((key, value) {
//           if (key.toString() == 'Images') {
//             Map elementsds = value;
//             elementsds.forEach((key, value) {
//               Map detailsds = value;
//               detailsds.forEach((key, value) {
//                 if (key.toString() == 'imageurl') {
//                   tempurl = value.toString();
//                 } else if (key.toString() == 'txt') {
//                   temptxt = value.toString();
//                 } else if (key.toString() == 'owner') {
//                   tempowner = value.toString();
//                 } else if (key.toString() == 'Liked by') {
//                   Map likedds = value;
//                   if (likedds.containsKey(details.userEmail
//                       .substring(0, details.userEmail.length - 4))) {
//                     //CHECKING IF THE LOGGED IN USER LIKED THIS IMAGE, DO NOT CHANGE ITS CORRECT
//                     templiked = true;
//                   } else {
//                     templiked = false;
//                   }
//                 }
//               });
//               wallpaperlist.add(new Wallpaper.ifImage(
//                   Image.network(
//                     tempurl,
//                   ),
//                   Text(temptxt),
//                   tempowner,
//                   templiked,
//                   userlist[count].dpUrl,
//                   userlist[count].userEmail,
//                   userlist[count].userName));

//               templiked = false;
//               //THE ABOVE IMPLEMENTATION IS FOR EVERY SINGLE IMAGE IN THE DATABASE OF ALL USERS
//               //START THE IMPLEMENTATION OF FOLLOWERS AND FOLLOWING TO DISPLAY ONLY LOGGEDIN USERS IMAGES AND THE FOLLOWING USERS IMAGES
//               //WILL PROBABLY HAVE TO CREATE A CLASS TO STORE THE OWNER AND COUNT SO WE CAN DYNAMICALLY ACCESS THE COUNT FOR DESIRED USERS
//             });
//           }
//         });
//         count++;
//       });
//       setState(() {});
//     });
//   }

//   initUsers() {
//     wallpaperdb.once().then((ds) {
//       Map emailsds = ds.value;
//       emailsds.forEach((key, value) async {
//         // tempemail = key.toString();
//         Map udds = value;
//         udds.forEach((key, value) {
//           if (key.toString() == 'UserDetails') {
//             // tempdpurl = value;
//             Map detailsds = value;
//             detailsds.forEach((key, value) {
//               if (key.toString() == 'photoUrl') {
//                 tempdpurl = value;
//               } else if (key.toString() == 'userEmail') {
//                 tempemail = value;
//               } else if (key.toString() == 'userName') {
//                 tempuname = value;
//               }
//             });
//           }
//         });
//         userlist.add(UserDisplayDetails(tempdpurl, tempemail, tempuname));
//       });
//     });
//   }
// }
