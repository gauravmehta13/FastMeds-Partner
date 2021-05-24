import 'package:fastmeds/Screens/Home%20Page.dart';
import 'package:fastmeds/Auth/onboarding_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Constants/Constants.dart';
import 'Screens/OnBoarding/Mandatory KYC.dart';

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
  bool loading = kIsWeb ? true : false;
  late Widget home =
      _auth.currentUser != null ? HomeScreen() : OnboardingScreen();

  void initState() {
    if (kIsWeb) {
      final subscription = FirebaseAuth.instance.idTokenChanges().listen(null);
      subscription.onData((event) async {
        if (event != null) {
          setState(() {
            home = HomeScreen();
          });
          subscription.cancel();
          setState(() {
            loading = false;
          });
          print(FirebaseAuth.instance.currentUser);
        } else {
          print("No user yet..");
          await Future.delayed(Duration(seconds: 4));
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
    return loading
        ? Container(child: Center(child: CircularProgressIndicator()))
        : MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FastMeds',
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
            home: home
            // home: MandatoryKYC()
            );
  }
}
