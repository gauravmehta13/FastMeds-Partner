import 'package:fastmeds/Constants/Constants.dart';
import 'package:fastmeds/Screens/OnBoarding/Pharmacy.dart';
import 'package:fastmeds/Screens/OnBoarding/Select%20Tenant.dart';
import 'package:fastmeds/Screens/Profile.dart';
import 'package:fastmeds/models/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../Screens/Home Page.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    // this.checkAuthentification();
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/images/onboarding_illustration.png',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 7,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'FastMeds',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 50,
                        color: kTitleTextColor,
                      ),
                    ),
                    box20,
                    Text(
                      'Prebook The Meds\nYou Want',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: kTitleTextColor.withOpacity(0.7),
                      ),
                    ),
                    box20,
                    loading
                        ? CircularProgressIndicator()
                        : MaterialButton(
                            color: Colors.white,
                            elevation: 10,
                            height: 45,
                            onPressed: () {
                              setState(() {
                                loading = true;
                              });
                              googleLogin();
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(color: Color(0xff3b5998))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/google.png', scale: 3),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'Get Started',
                                  style: TextStyle(color: Color(0xff3b5998)),
                                )
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future googleLogin() async {
    try {
      final user = await googleSignIn.signIn();
      if (user == null) {
        return;
      } else {
        final googleAuth = await user.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth.signInWithCredential(credential).then((value) async {
          print(value.additionalUserInfo!.isNewUser);
          if (value.additionalUserInfo!.isNewUser) {
            await DatabaseService(_auth.currentUser!.uid).updateUserData("");
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => SelectTenant()));
          } else {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          }
          setState(() {
            loading = false;
          });
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      displaySnackBar("Error, please try again later..!!", context);
    }
  }

  // checkAuthentification() async {
  //   _auth.authStateChanges().listen((user) {
  //     if (user != null) {
  //       print(user);
  //       Navigator.pushReplacement(
  //           context, MaterialPageRoute(builder: (context) => HomeScreen()));
  //     }
  //   });
  // }
}
