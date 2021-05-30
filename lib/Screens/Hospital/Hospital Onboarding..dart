import 'package:fastmeds/models/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Hospital extends StatefulWidget {
  @override
  _HospitalState createState() => _HospitalState();
}

class _HospitalState extends State<Hospital> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void initState() {
    super.initState();
    DatabaseService(_auth.currentUser!.uid).updateUserData("Hospital");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
