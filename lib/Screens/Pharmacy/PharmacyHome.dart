import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fastmeds/Constants/Constants.dart';
import 'package:fastmeds/Screens/Drawer.dart';
import 'package:fastmeds/Screens/Select%20Tenant.dart';
import 'package:fastmeds/Widgets/Loading.dart';
import 'package:fastmeds/models/tenantData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../Fade Route.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class PharmacyHome extends StatefulWidget {
  @override
  _PharmacyHomeState createState() => _PharmacyHomeState();
}

class _PharmacyHomeState extends State<PharmacyHome> {
  CollectionReference pharmacy =
      FirebaseFirestore.instance.collection('Pharmacy');
  bool loading = true;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  late PharmacyDetails data;

  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    try {
      await pharmacy
          .doc(_auth.currentUser!.uid)
          .get()
          .then((DocumentSnapshot<Object?> querySnapshot) {
        data = PharmacyDetails.fromMap(querySnapshot);
      });
      print(data);
      setState(() {
        loading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      drawer: MyDrawer(),
      backgroundColor: kBackgroundColor,
      body: loading
          ? Loading()
          : SafeArea(
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
                              backgroundImage: NetworkImage(data.imgUrl)),
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
                          "Hello ${data.pharmacyName}",
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
                      data.phone,
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
