import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fastmeds/Auth/onboarding_screen.dart';
import 'package:fastmeds/Screens/Select%20Tenant.dart';
import 'package:fastmeds/Screens/Hospital/Hospital%20Onboarding..dart';
import 'package:fastmeds/Screens/Pharmacy/PharmacyHome.dart';
import 'package:fastmeds/Widgets/Loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Constants/Constants.dart';
import 'models/tenantData.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

final FirebaseAuth _auth = FirebaseAuth.instance;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = true;
  late Widget home =
      _auth.currentUser != null ? Hospital() : OnboardingScreen();

  void initState() {
    if (!kIsWeb) {
      final subscription = FirebaseAuth.instance.idTokenChanges().listen(null);
      subscription.onData((event) async {
        if (event != null) {
          await FirebaseFirestore.instance
              .collection('Tenant')
              .doc(_auth.currentUser!.uid)
              .get()
              .then((DocumentSnapshot<Object?> querySnapshot) {
            var data = TenantDetails.fromMap(querySnapshot);
            if (data.tenant == "Pharmacy") {
              setState(() {
                home = PharmacyHome();
              });
            } else if (data.tenant == "Pharmacy") {
            } else if (data.tenant == "Pharmacy") {
            } else if (data.tenant == "Pharmacy") {
            } else if (data.tenant == "Pharmacy") {
            } else if (data.tenant == "Pharmacy") {}
          });
          subscription.cancel();
          setState(() {
            loading = false;
          });
        } else {
          print("No user yet..");
          await Future.delayed(Duration(seconds: kIsWeb ? 4 : 1));
          if (loading) {
            setState(() {
              home = OnboardingScreen();
            });
            subscription.cancel();
            setState(() {
              loading = false;
            });
          }
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FastMeds Partner',
        theme: ThemeData(
          appBarTheme: Theme.of(context)
              .appBarTheme
              .copyWith(brightness: Brightness.light),
          textTheme: GoogleFonts.montserratTextTheme(
            Theme.of(context).textTheme,
          ),
          primaryColor: primaryColor,
          accentColor: primaryColor,
          backgroundColor: primaryColor,
        ),
        home: loading ? Scaffold(body: Loading()) : SelectTenant());
  }
}
