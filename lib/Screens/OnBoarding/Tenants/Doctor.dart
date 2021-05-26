import 'package:fastmeds/models/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Doctor extends StatefulWidget {
  @override
  _DoctorState createState() => _DoctorState();
}

class _DoctorState extends State<Doctor> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void initState() {
    super.initState();
    DatabaseService(_auth.currentUser!.uid).updateUserData("Doctor");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
