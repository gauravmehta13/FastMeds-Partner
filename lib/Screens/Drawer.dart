import 'package:fastmeds/Constants/Constants.dart';
import 'package:fastmeds/Screens/Home%20Page.dart';
import 'package:fastmeds/Auth/onboarding_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  void initState() {
    //  FirebaseAnalytics().logEvent(name: 'App_Drawer', parameters: null);
    super.initState();
  }

  var userName = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      color: Colors.white,
      child: Drawer(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                height: AppBar().preferredSize.height,
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: double.maxFinite,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(color: Color(0xFF3f51b5)),
                child: _auth.currentUser != null
                    ? Row(
                        children: [
                          if (_auth.currentUser != null)
                            Text((_auth.currentUser!.displayName ?? ""),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.white,
                                )),
                        ],
                      )
                    : Text("FastMeds",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        )),
              ),
              ListTile(
                dense: true, // minLeadingWidth: 25,
                onTap: () {
                  Navigator.pop(context);
                },
                title: Text("Home"),
                leading: FaIcon(
                  FontAwesomeIcons.home,
                  color: Colors.black87,
                  size: 18,
                ),
              ),
              Spacer(),
              ListTile(
                dense: true,
                onTap: () {
                  FirebaseAnalytics()
                      .logEvent(name: 'Contact_Us', parameters: null);
                  _sendMail();
                },
                title: Text(
                  "Contact Us",
                ),
                leading: FaIcon(
                  FontAwesomeIcons.mailBulk,
                  color: Colors.black87,
                  size: 18,
                ),
              ),
              if (_auth.currentUser != null)
                ListTile(
                  dense: true,
                  onTap: () async {
                    _auth.signOut().then((_) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (_) => OnboardingScreen()));
                    });
                  },
                  title: Text("SignOut"),
                  leading: FaIcon(
                    FontAwesomeIcons.signOutAlt,
                    color: Colors.black87,
                    size: 18,
                  ),
                ),
              Container(
                color: primaryColor,
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Text("Powered By DevsEra",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

_sendMail() async {
  // Android and iOS
  const uri = 'mailto:fastmeds@gmail.com';
  if (await canLaunch(uri)) {
    await launch(uri);
  } else {
    throw 'Could not launch $uri';
  }
}
