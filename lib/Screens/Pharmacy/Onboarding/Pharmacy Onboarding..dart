import 'dart:io';
import 'package:fastmeds/Constants/Constants.dart';
import 'package:fastmeds/Widgets/Loading.dart';
import 'package:fastmeds/Widgets/Progress%20Appbar.dart';
import 'package:fastmeds/models/database.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class PharmacyOnBoarding extends StatefulWidget {
  final edit;
  PharmacyOnBoarding({this.edit});
  @override
  _PharmacyOnBoardingState createState() => _PharmacyOnBoardingState();
}

class _PharmacyOnBoardingState extends State<PharmacyOnBoarding> {
  late File imageFile;
  late bool isLoading;
  late String imageUrl = "";
  var dio = Dio();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  bool sendingData = false;
  final formKey = GlobalKey<FormState>();
  var companyName = new TextEditingController();
  var streetAddress = new TextEditingController();
  var otpController = new TextEditingController();
  var phone = new TextEditingController();
  bool uploadingImage = false;
  final ScrollController scrollController = ScrollController();
  var feature1OverflowMode = OverflowMode.clipContent;
  var feature1EnablePulsingAnimation = true;
  var ensureKey = GlobalKey<EnsureVisibleState>();
  late ConfirmationResult confirmationResult;

  @override
  void initState() {
    super.initState();
    // DatabaseService(_auth.currentUser!.uid).updateUserData("Pharmacy");
    // DatabaseService(_auth.currentUser!.uid).updatePharmacyData(
    //     "", "", "", "", "", "", "", "", "", "", "", "", "", 0, 0);
  }

  scrollToTop() {
    scrollController.animateTo(scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
  }

  var verificationCode = '';

  var isResend = false;
  var isRegister = true;
  bool otp = false;
  var isOTPScreen = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: myAppBar(2, "Pharmacy Registration", context),
        key: _scaffoldKey,
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(20, 5, 20, 20),
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFf9a825), // background
                onPrimary: Colors.white, // foreground
              ),
              onPressed: loading == true || uploadingImage == true
                  ? null
                  : () async {
                      linkPhone();

                      // if (formKey.currentState!.validate()) {
                      //   if (imageUrl == "") {
                      //     FeatureDiscovery.clearPreferences(context, <String>{
                      //       'image',
                      //     });
                      //     FeatureDiscovery.discoverFeatures(
                      //       context,
                      //       const <String>{"image"},
                      //     );

                      //     return;
                      //   }
                      //   setState(() {
                      //     sendingData = true;
                      //   });
                      //   GeoFirePoint myLocation =
                      //       geo.point(latitude: lat, longitude: lon);
                      //   print(myLocation.data.toString());
                      //   await DatabaseService(_auth.currentUser!.uid)
                      //       .updatePharmacyData(
                      //     companyName.text,
                      //     phone.text,
                      //     pinCode.text,
                      //     postOffice,
                      //     pickupData[0]["Block"],
                      //     pickupData[0]["Division"],
                      //     pickupData[0]["State"],
                      //     streetAddress.text,
                      //     imageUrl,
                      //     _auth.currentUser!.email!,
                      //     _auth.currentUser!.photoURL!,
                      //     _auth.currentUser!.displayName!,
                      //     myLocation.data,
                      //     lat,
                      //     lon,
                      //   );
                      //   setState(() {
                      //     sendingData = false;
                      //   });
                      //   Navigator.pushReplacement(
                      //     context,
                      //     FadeRoute(page: PharmacyHome()),
                      //   );
                      // }
                    },
              child: sendingData == true || uploadingImage == true
                  ? Column(
                      children: [
                        Text(""),
                        Center(
                          child: LinearProgressIndicator(
                            backgroundColor: Color(0xFF3f51b5),
                            valueColor: AlwaysStoppedAnimation(
                              Color(0xFFf9a825),
                            ),
                          ),
                        ),
                        Text("Please Wait")
                      ],
                    )
                  : Text(
                      "Next",
                      style: TextStyle(color: Colors.black),
                    ),
            ),
          ),
        ),
        body: loading == true
            ? Loading()
            : SafeArea(
                child: SingleChildScrollView(
                    controller: scrollController,
                    child: Form(
                      key: formKey,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            DescribedFeatureOverlay(
                              featureId: "image",
                              tapTarget: Icon(FontAwesomeIcons.camera),
                              backgroundColor: primaryColor.withOpacity(0.1),
                              contentLocation: ContentLocation.trivial,
                              title: const Text(
                                'Upload Image of your Pharmacy',
                                style: TextStyle(backgroundColor: primaryColor),
                              ),
                              description: const Text(
                                'Profile with Images attracts\nmore customers.',
                                style: TextStyle(backgroundColor: primaryColor),
                              ),
                              //onComplete: action,
                              onOpen: () async {
                                print('The overlay is about to be displayed.');
                                WidgetsBinding.instance!
                                    .addPostFrameCallback((_) {
                                  ensureKey.currentState!.ensureVisible(
                                    preciseAlignment: 0.5,
                                    duration: const Duration(milliseconds: 400),
                                  );
                                });
                                return true;
                              },
                              child: EnsureVisible(
                                key: ensureKey,
                                child: GestureDetector(
                                  onTap: () {
                                    getImage();
                                  },
                                  child: Stack(
                                    children: [
                                      imageUrl != ""
                                          ? CircleAvatar(
                                              radius: 60,
                                              backgroundColor: Colors.grey[300],
                                              backgroundImage: NetworkImage(
                                                imageUrl,
                                              ))
                                          : CircleAvatar(
                                              radius: 60,
                                              backgroundColor: Colors.grey[300],
                                              child: uploadingImage
                                                  ? CircularProgressIndicator()
                                                  : Image.asset(
                                                      "assets/pharmacy.png"),
                                            ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: CircleAvatar(
                                            backgroundColor: primaryColor,
                                            radius: 20,
                                            child: Icon(
                                              FontAwesomeIcons.camera,
                                              color: Colors.white,
                                              size: 16,
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            box10,
                            Text(
                              "Lets build your dedicated profile",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 20),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                                width: double.maxFinite,
                                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                decoration: BoxDecoration(
                                  color: Color(0xFFc1f0dc),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(
                                    "85% customers prefer to select a Pharmacy with a complete profile.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF2f7769),
                                      fontSize: 12,
                                    ),
                                  ),
                                )),
                            SizedBox(
                              height: 30,
                            ),
                            new TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: companyName,
                              decoration: new InputDecoration(
                                  prefixIcon:
                                      Icon(FontAwesomeIcons.addressCard),
                                  isDense: true, // Added this
                                  contentPadding: EdgeInsets.all(15),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Color(0xFF2821B5),
                                    ),
                                  ),
                                  border: new OutlineInputBorder(
                                      borderSide: new BorderSide(
                                          color: Colors.grey[200]!)),
                                  labelText: "Pharmacy Name"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                            box20,
                            new TextFormField(
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              textInputAction: TextInputAction.next,
                              controller: phone,
                              decoration: textfieldDecoration(
                                  "Contact Number", Icons.phone),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    )),
              ));
  }

  Future getImage() async {
    PickedFile selectedFile;

    selectedFile = (await ImagePicker().getImage(source: ImageSource.gallery))!;

    if (selectedFile != null) {
      setState(() {
        uploadingImage = true;
      });
      uploadFile(selectedFile);
    }
  }

  Future uploadFile(PickedFile orFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    firebase_storage.Reference reference =
        firebase_storage.FirebaseStorage.instance.ref().child(fileName);

    late File compressedFile;
    if (!kIsWeb)
      compressedFile = await FlutterNativeImage.compressImage(orFile.path,
          quality: 80, percentage: 90);

    try {
      firebase_storage.UploadTask uploadTask;

      final metadata = firebase_storage.SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': orFile.path});

      if (kIsWeb)
        uploadTask = reference.putData(await orFile.readAsBytes(), metadata);
      else
        uploadTask = reference.putFile(compressedFile);

      firebase_storage.TaskSnapshot storageTaskSnapshot = await uploadTask;

      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
        imageUrl = downloadUrl;
        print(downloadUrl);
        setState(() {
          uploadingImage = false;
        });
      }, onError: (err) {
        setState(() {
          uploadingImage = false;
        });
        displaySnackBar("Error Uploading Image", context);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  clearCaptcha() {
    if (kIsWeb) {
      print("Clearing Captcha");
      RecaptchaVerifier().clear();
    }
  }

  linkPhone() async {
    if (formKey.currentState!.validate()) {
      try {
        var phoneNumber = '+91 ' + phone.text.trim();
        if (kIsWeb) {
          confirmationResult = await _auth.currentUser!
              .linkWithPhoneNumber(phoneNumber, RecaptchaVerifier());
        } else {
          //ok, we have a valid user, now lets do otp verification
          var verifyPhoneNumber = _auth.verifyPhoneNumber(
            phoneNumber: phoneNumber,
            verificationCompleted: (phoneAuthCredential) {
              //auto code complete (not manually)
              _auth.currentUser!
                  .linkWithCredential(phoneAuthCredential)
                  .then((user) async {
                displaySnackBar("Success", context);
                setState(() {
                  isLoading = false;
                  isResend = false;
                });
              }).catchError((error) {
                print(error);
                if (error.toString().contains("already been linked")) {
                  displaySnackBar("Already Linked", context);
                  print("already Linked");
                }
              });
            },
            verificationFailed: (FirebaseAuthException error) {
              print(error);
              displaySnackBar(error.toString(), context);

              setState(() {
                isLoading = false;
                otp = false;
              });
            },
            codeSent: (verificationId, [forceResendingToken]) {
              setState(() {
                isLoading = false;
                verificationCode = verificationId;
                isOTPScreen = true;
              });
            },
            codeAutoRetrievalTimeout: (String verificationId) {
              setState(() {
                isLoading = false;
                verificationCode = verificationId;
              });
            },
            timeout: Duration(seconds: 60),
          );
          await verifyPhoneNumber;
        }
      } catch (error) {
        displaySnackBar(error.toString(), context);
        print(error.toString());
      }
    }
  }

  verifyOTP() async {
    // if (_formKeyOTP.currentState.validate()) {
    clearCaptcha();
    setState(() {
      isResend = false;
      isLoading = true;
    });

    print(kIsWeb);
    if (kIsWeb) {
      await confirmationResult.confirm(otpController.text).then((user) {
        displaySnackBar("Success", context);
        setState(() {
          isLoading = false;
          isResend = false;
        });
      });
    }
    if (!kIsWeb) {
      try {
        _auth.currentUser!
            .linkWithCredential(PhoneAuthProvider.credential(
                verificationId: verificationCode,
                smsCode: otpController.text.toString()))
            .then((user) async {
          displaySnackBar("Success", context);
          setState(() {
            isLoading = false;
            isResend = false;
          });
        }).catchError((error) {
          print(error);
          if (error.toString().contains("already been linked")) {
            displaySnackBar("Already Linked", context);
            print("already Linked");
          }
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
