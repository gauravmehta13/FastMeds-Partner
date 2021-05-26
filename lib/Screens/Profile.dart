import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fastmeds/Constants/Constants.dart';
import 'package:fastmeds/Screens/Drawer.dart';
import 'package:fastmeds/Screens/OnBoarding/Pharmacy.dart';
import 'package:fastmeds/Screens/OnBoarding/Select%20Tenant.dart';
import 'package:fastmeds/Widgets/Loading.dart';
import 'package:fastmeds/components/search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../Fade Route.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Shops")
            .doc(_auth.currentUser!.uid) //ID OF DOCUMENT
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Loading();
          }
          dynamic document = snapshot.data;
          if (document["phone"] == "") {
            Navigator.pushReplacement(
              context,
              FadeRoute(page: SelectTenant()),
            );
          }
          return Scaffold(
            key: _drawerKey,
            drawer: MyDrawer(),
            backgroundColor: kBackgroundColor,
            body: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                            onTap: () {
                              _drawerKey.currentState!.openDrawer();
                            },
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                              child: SvgPicture.asset('assets/icons/menu.svg'),
                            )),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                          child: CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              backgroundImage: NetworkImage(_auth
                                      .currentUser!.photoURL ??
                                  "https://i.pinimg.com/originals/51/f6/fb/51f6fb256629fc755b8870c801092942.png")),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello ${_auth.currentUser!.displayName}",
                          style: TextStyle(
                            fontSize: 18,
                            color: kTitleTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        box10,
                      ],
                    ),
                    Text(
                      document?["shopName"] ?? "",
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(document["phone"]),
                    Text(document["gstNo"]),
                    Text(
                        "${document!["address"]}, ${document!["city"]}, ${document!["state"]}")
                  ],
                ),
              ),
            ),
          );
        });
  }
}
