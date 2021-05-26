import 'package:fastmeds/models/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DiagnosticLab extends StatefulWidget {
  @override
  _DiagnosticLabState createState() => _DiagnosticLabState();
}

class _DiagnosticLabState extends State<DiagnosticLab> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void initState() {
    super.initState();
    DatabaseService(_auth.currentUser!.uid).updateUserData("DiagnosticLab");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
