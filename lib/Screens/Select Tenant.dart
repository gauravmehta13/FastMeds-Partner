import 'package:fastmeds/Constants/Constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Fade Route.dart';
import 'Ambulance/Ambulance Onboarding..dart';
import 'Diagnostic Labs/Diagnostic Lab Onboarding..dart';
import 'Volunteer/Volunteer Onboarding.dart';
import 'Doctor/Doctor  Onboarding..dart';
import 'Hospital/Hospital Onboarding..dart';
import 'Pharmacy/Onboarding/Pharmacy Onboarding..dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SelectTenant extends StatefulWidget {
  @override
  _SelectTenantState createState() => _SelectTenantState();
}

class _SelectTenantState extends State<SelectTenant> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: primaryColor),
          elevation: 0,
          backgroundColor: kBackgroundColor,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: kBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        backgroundImage: NetworkImage(_auth
                                .currentUser?.photoURL ??
                            "https://i.pinimg.com/originals/51/f6/fb/51f6fb256629fc755b8870c801092942.png")),
                    box20,
                    Text(
                      "Welcome ${_auth.currentUser?.displayName?.split(" ")[0] ?? ""},",
                      style: TextStyle(
                        fontSize: 18,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Register as:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20),
                      itemCount: gridData.length,
                      itemBuilder: (BuildContext ctx, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              FadeRoute(page: gridData[index]["page"]),
                            );
                          },
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    gridData[index]["icon"],
                                    color: primaryColor.withOpacity(0.7),
                                  ),
                                  Text(
                                    gridData[index]["title"],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: primaryColor, fontSize: 13),
                                  ),
                                ],
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          ),
        ));
  }
}

List gridData = [
  {"title": "Doctor", "page": Doctor(), "icon": FontAwesomeIcons.stethoscope},
  {
    "title": "Hospital",
    "page": HospitalOnBoarding(),
    "icon": FontAwesomeIcons.hospital
  },
  {
    "title": "Volunteer",
    "page": Volunteer(),
    "icon": FontAwesomeIcons.handsHelping
  },
  {
    "title": "Ambulance",
    "page": AmbulanceOnBoarding(),
    "icon": FontAwesomeIcons.ambulance
  },
  {
    "title": "Pharmacy",
    "page": PharmacyOnBoarding(),
    "icon": FontAwesomeIcons.pills
  },
  {
    "title": "Diagnostic\nLabs",
    "page": DiagnosticLabOnBoarding(),
    "icon": FontAwesomeIcons.thermometerThreeQuarters
  },
];
