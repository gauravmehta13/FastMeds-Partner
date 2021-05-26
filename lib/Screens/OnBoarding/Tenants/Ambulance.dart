import 'package:fastmeds/models/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Ambulance extends StatefulWidget {
  @override
  _AmbulanceState createState() => _AmbulanceState();
}

class _AmbulanceState extends State<Ambulance> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void initState() {
    super.initState();
    DatabaseService(_auth.currentUser!.uid).updateUserData("Ambulance");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
