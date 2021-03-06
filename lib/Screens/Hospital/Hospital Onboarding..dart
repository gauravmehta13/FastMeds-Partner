import 'dart:io';
import 'package:fastmeds/Constants/Constants.dart';
import 'package:fastmeds/Constants/Districts.dart';
import 'package:fastmeds/Screens/Pharmacy/PharmacyHome.dart';
import 'package:fastmeds/Widgets/Loading.dart';
import 'package:fastmeds/models/database.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import '../../Fade Route.dart';
import 'package:dropdown_search/dropdown_search.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class HospitalOnBoarding extends StatefulWidget {
  final edit;
  HospitalOnBoarding({this.edit});
  @override
  _HospitalOnBoardingState createState() => _HospitalOnBoardingState();
}

class _HospitalOnBoardingState extends State<HospitalOnBoarding> {
  Location location = new Location();
  late double lat;
  late double lon;
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  bool gettingPinData = false;
  late File imageFile;
  late bool isLoading;
  late String imageUrl = "";
  var pickupData;
  List<String> pickupOptions = [];
  var dio = Dio();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  bool sendingData = false;
  late String districtName = "";
  late String stateName = "";
  List<StateDistrictMapping> districtMapping = [];
  final formKey = GlobalKey<FormState>();
  var companyName = new TextEditingController();
  var streetAddress = new TextEditingController();
  var pinCode = new TextEditingController();
  var phone = new TextEditingController();
  bool uploadingImage = false;
  late String postOffice;
  final ScrollController scrollController = ScrollController();
  final geo = Geoflutterfire();
  var feature1OverflowMode = OverflowMode.clipContent;
  var feature1EnablePulsingAnimation = false;
  var ensureKey = GlobalKey<EnsureVisibleState>();

  @override
  void initState() {
    super.initState();
    DatabaseService(_auth.currentUser!.uid).updateUserData("Hospital");
    DatabaseService(_auth.currentUser!.uid).updateHospitalData(
        "", "", "", "", "", "", "", "", "", "", "", "", "", 0, 0);
    getLocation();
  }

  getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    print(_locationData.latitude!.toString());
    print(_locationData.longitude!.toString());
    setState(() {
      lat = _locationData.latitude!;
      lon = _locationData.longitude!;
    });
    getPinCode(lat.toString(), lon.toString());
  }

  getPinCode(lat, lon) async {
    var dio = Dio();
    final resp = await dio.get(
        "https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon");
    print(resp.data);
    pinCode.text = resp.data["address"]["postcode"];
    getPinData(int.parse(resp.data["address"]["postcode"].toString()));
  }

  getLatLong(pin) async {
    var dio = Dio();
    final resp = await dio.get(
        "https://nominatim.openstreetmap.org/search?format=json&postalcode=$pin");
    print(resp.data);
    var loc = resp.data[0];
    setState(() {
      lat = double.tryParse(loc["lat"].toString())!;
      lon = double.tryParse(loc["lon"].toString())!;
    });
    print("Latitude : ${lat.toString()} & Longitude : ${lon.toString()}");
  }

  scrollToTop() {
    scrollController.animateTo(scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Hopspital Registration",
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600, fontSize: 16),
          ),
          centerTitle: true,
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.help_outline))
          ],
        ),
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
                      if (formKey.currentState!.validate()) {
                        if (imageUrl == "") {
                          FeatureDiscovery.clearPreferences(context, <String>{
                            'image',
                          });
                          FeatureDiscovery.discoverFeatures(
                            context,
                            const <String>{"image"},
                          );

                          return;
                        }
                        setState(() {
                          sendingData = true;
                        });
                        GeoFirePoint myLocation =
                            geo.point(latitude: lat, longitude: lon);
                        print(myLocation.data.toString());
                        await DatabaseService(_auth.currentUser!.uid)
                            .updateHospitalData(
                          companyName.text,
                          phone.text,
                          pinCode.text,
                          postOffice,
                          pickupData[0]["Block"],
                          pickupData[0]["Division"],
                          pickupData[0]["State"],
                          streetAddress.text,
                          imageUrl,
                          _auth.currentUser!.email!,
                          _auth.currentUser!.photoURL!,
                          _auth.currentUser!.displayName!,
                          myLocation.data,
                          lat,
                          lon,
                        );
                        setState(() {
                          sendingData = false;
                        });
                        Navigator.pushReplacement(
                          context,
                          FadeRoute(page: PharmacyHome()),
                        );
                      }
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
                      "Save",
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
                                'Upload Hopsital Image',
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
                                                      "assets/hospital.png"),
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
                                    "85% customers prefer to select a Hospital\nwith a complete details.",
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
                                  labelText: "Hospital Name"),
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
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              textInputAction: TextInputAction.next,
                              controller: pinCode,
                              onChanged: (pin) async {
                                var pickupPin = int.tryParse(pin);
                                var count = 0, temp = pickupPin;
                                while (temp! > 0) {
                                  count++;
                                  temp = (temp / 10).floor();
                                }
                                print(count);
                                setState(() {
                                  pickupOptions = [];
                                });
                                if (count == 6) {
                                  getLatLong(pin.toString());
                                  getPinData(pin);
                                }
                              },
                              decoration: new InputDecoration(
                                  isDense: true,
                                  suffix: gettingPinData
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator())
                                      : null,
                                  counterText: "",
                                  prefixIcon:
                                      Icon(FontAwesomeIcons.locationArrow),
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
                                  labelText: "Pin Code"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                            if (pickupOptions.length != 0)
                              Column(
                                children: [
                                  box5,
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    child: Text(pickupData != null
                                        ? "${pickupData[0]["District"]}, ${pickupData[0]["State"]}"
                                        : ""),
                                  ),
                                  box20,
                                  DropdownSearch<String>(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                    dropdownSearchDecoration: InputDecoration(
                                      prefixIcon: Icon(FontAwesomeIcons.city),
                                      isDense: true, // Added this
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 3, horizontal: 5),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                        borderSide: BorderSide(
                                          width: 1,
                                          color: Color(0xFF2821B5),
                                        ),
                                      ),
                                      border: new OutlineInputBorder(
                                          borderSide: new BorderSide(
                                              color: Color(0xFF23232))),
                                    ),
                                    mode: Mode.MENU,
                                    showSelectedItem: true,
                                    items: pickupOptions,
                                    label: "Select Area",
                                    hint: "Your Area name",
                                    onChanged: (e) {
                                      setState(() {
                                        postOffice = e!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            box20,
                            new TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: streetAddress,
                              decoration: new InputDecoration(
                                  isDense: true, // Added this
                                  prefixIcon: Icon(FontAwesomeIcons.building),
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
                                  labelText: "Street Address"),
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

  getPinData(pin) async {
    setState(() {
      gettingPinData = true;
    });
    var response = await dio.get("https://api.postalpincode.in/pincode/$pin");
    print(response.data);
    var data = response.data;
    setState(() {
      pickupOptions = [];
    });
    for (int i = 0; i < data[0]["PostOffice"].length; i++) {
      pickupOptions.add(data[0]["PostOffice"][i]["Name"]);
    }

    setState(() {
      pickupData = data[0]["PostOffice"];
      pickupOptions = pickupOptions;
    });
    print(pickupOptions);
    print(pickupData);
    setState(() {
      gettingPinData = false;
    });
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
}
