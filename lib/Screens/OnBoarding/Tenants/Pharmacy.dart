import 'dart:convert';
import 'dart:io';
import 'package:fastmeds/Constants/Constants.dart';
import 'package:fastmeds/Constants/Districts.dart';
import 'package:fastmeds/Screens/Profile.dart';
import 'package:fastmeds/models/database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert' as convert;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import '../../../Fade Route.dart';
import 'package:dropdown_search/dropdown_search.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Pharmacy extends StatefulWidget {
  final edit;
  Pharmacy({this.edit});
  @override
  _PharmacyState createState() => _PharmacyState();
}

class _PharmacyState extends State<Pharmacy> {
  late File imageFile;
  late bool isLoading;
  late String imageUrl = "";
  var pickupData;
  List<String> pickupOptions = [];
  var dio = Dio();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  bool sendingData = false;
  bool kycCompleted = false;
  late String districtName = "";
  late String stateName = "";
  List<StateDistrictMapping> districtMapping = [];
  final formKey = GlobalKey<FormState>();
  var companyName = new TextEditingController();
  var streetAddress = new TextEditingController();
  var pinCode = new TextEditingController();
  var phone = new TextEditingController();
  bool uploadingImage = false;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    DatabaseService(_auth.currentUser!.uid).updateUserData("Pharmacy");
    districtMapping = StateDistrictMapping.getDsitricts();
  }

  scrollToTop() {
    scrollController.animateTo(scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          displaySnackBar("Please Upload Image", context);
                          return;
                        }
                        setState(() {
                          sendingData = true;
                        });
                        await DatabaseService(_auth.currentUser!.uid)
                            .updatePharmacyData(
                                companyName.text,
                                pinCode.text,
                                streetAddress.text,
                                districtName,
                                stateName,
                                phone.text,
                                imageUrl);
                        setState(() {
                          sendingData = false;
                        });
                        Navigator.pushReplacement(
                          context,
                          FadeRoute(page: HomePage()),
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
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                    controller: scrollController,
                    child: kycCompleted == true
                        ? Container()
                        : Form(
                            key: formKey,
                            child: Container(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  box10,
                                  SizedBox(
                                      height: 80,
                                      child: Image.asset("assets/kyc.png")),
                                  box10,
                                  Text(
                                    "Verify Your Identity   ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                      width: double.maxFinite,
                                      padding:
                                          EdgeInsets.fromLTRB(10, 5, 10, 5),
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4)),
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
                                  Column(
                                    children: [
                                      Column(
                                        children: [
                                          Autocomplete<StateDistrictMapping>(
                                            displayStringForOption: (option) =>
                                                option.district,
                                            fieldViewBuilder: (context,
                                                    textEditingController,
                                                    focusNode,
                                                    onFieldSubmitted) =>
                                                TextFormField(
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .onUserInteraction,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Required';
                                                      }
                                                      return null;
                                                    },
                                                    scrollPadding:
                                                        const EdgeInsets.only(
                                                            bottom: 150.0),
                                                    controller:
                                                        textEditingController,
                                                    onTap: () {
                                                      textEditingController
                                                          .clear();
                                                      setState(() {
                                                        stateName = "";
                                                      });
                                                    },
                                                    focusNode: focusNode,
                                                    decoration:
                                                        textfieldDecoration(
                                                            "Select City",
                                                            FontAwesomeIcons
                                                                .city)),
                                            optionsBuilder: (textEditingValue) {
                                              if (textEditingValue.text == '') {
                                                return districtMapping;
                                              }
                                              return districtMapping.where((s) {
                                                return s.district
                                                    .toLowerCase()
                                                    .contains(textEditingValue
                                                        .text
                                                        .toLowerCase());
                                              });
                                            },
                                            onSelected: (StateDistrictMapping
                                                selection) {
                                              final FocusScopeNode
                                                  currentScope =
                                                  FocusScope.of(context);
                                              if (!currentScope
                                                      .hasPrimaryFocus &&
                                                  currentScope.hasFocus) {
                                                FocusManager
                                                    .instance.primaryFocus!
                                                    .unfocus();
                                              }
                                              print(selection.district);
                                              print(selection.districtID);
                                              setState(() {
                                                districtName = selection
                                                    .district
                                                    .toString();
                                                stateName =
                                                    selection.state.toString();
                                              });
                                              scrollToTop();
                                            },
                                          ),
                                          if (stateName.isNotEmpty)
                                            Container(
                                                padding:
                                                    EdgeInsets.only(top: 0),
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  stateName,
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ))
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      box20,
                                      new TextFormField(
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        controller: streetAddress,
                                        decoration: new InputDecoration(
                                            isDense: true, // Added this
                                            prefixIcon:
                                                Icon(FontAwesomeIcons.building),
                                            contentPadding: EdgeInsets.all(15),
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
                                                    color: Colors.grey[200]!)),
                                            labelText: "Street Address"),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Required';
                                          }
                                          return null;
                                        },
                                      ),
                                      box20,
                                      Row(
                                        children: [
                                          Expanded(
                                              child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            maxLength: 6,
                                            textInputAction:
                                                TextInputAction.next,
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
                                                getPinData() async {
                                                  var response = await dio.get(
                                                      "https://api.postalpincode.in/pincode/$pin");
                                                  print(response.data);
                                                  var data = json
                                                      .decode(response.data);
                                                  setState(() {
                                                    pickupOptions = [];
                                                  });
                                                  for (int i = 0;
                                                      i <
                                                          data[0]["PostOffice"]
                                                              .length;
                                                      i++) {
                                                    pickupOptions.add(data[0]
                                                            ["PostOffice"][i]
                                                        ["Name"]);
                                                  }

                                                  setState(() {
                                                    pickupData =
                                                        data[0]["PostOffice"];
                                                    pickupOptions =
                                                        pickupOptions;
                                                  });
                                                  print(pickupOptions);
                                                  print(pickupData);
                                                }

                                                getPinData();
                                              }
                                            },
                                            decoration: new InputDecoration(
                                                isDense: true,
                                                counterText: "",
                                                helperText: pickupData != null
                                                    ? "${pickupData[0]["District"]}, ${pickupData[0]["State"]}"
                                                    : "", // Added this
                                                prefixIcon: Icon(
                                                    FontAwesomeIcons
                                                        .locationArrow),
                                                contentPadding:
                                                    EdgeInsets.all(15),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(4)),
                                                  borderSide: BorderSide(
                                                    width: 1,
                                                    color: Color(0xFF2821B5),
                                                  ),
                                                ),
                                                border: new OutlineInputBorder(
                                                    borderSide: new BorderSide(
                                                        color:
                                                            Colors.grey[200]!)),
                                                labelText: "Pin Code"),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Required';
                                              }
                                              return null;
                                            },
                                          )),
                                          if (pickupOptions.length != 0)
                                            Column(
                                              children: [
                                                Container(
                                                  padding:
                                                      EdgeInsets.only(left: 5),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                    border: Border.all(
                                                        color: Colors.grey,
                                                        style:
                                                            BorderStyle.solid,
                                                        width: 0.80),
                                                  ),
                                                  child: DropdownSearch<String>(
                                                    // showSearchBox: true,
                                                    mode: Mode.MENU,
                                                    showSelectedItem: true,
                                                    items: states,
                                                    label: "Select State",
                                                    hint: "Your State name",
                                                    // popupItemDisabled: (String s) => s.startsWith('I'),
                                                    onChanged: (e) {},
                                                    validator: (String item) {
                                                      if (item == null)
                                                        return "Required";
                                                      else
                                                        return null;
                                                    },
                                                  ),
                                                  // child: DropDown(
                                                  //   showUnderline: false,
                                                  //   items: pickupOptions,
                                                  //   hint: Text("Select Pickup Area"),
                                                  //   onChanged: print,
                                                  // ),
                                                ),
                                                SizedBox(
                                                  height: 22,
                                                )
                                              ],
                                            )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Upload Image :",
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          uploadingImage
                                              ? CircularProgressIndicator()
                                              : imageUrl != ""
                                                  ? SizedBox(
                                                      height: 100,
                                                      width: 100,
                                                      child: Image.network(
                                                        imageUrl,
                                                        width: 100,
                                                        height: 100,
                                                      ),
                                                    )
                                                  : RawMaterialButton(
                                                      onPressed: () {
                                                        getImage();
                                                      },
                                                      elevation: 0,
                                                      fillColor:
                                                          Color(0xFFf9a825)
                                                              .withOpacity(0.3),
                                                      child: Icon(
                                                          FontAwesomeIcons
                                                              .upload),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)))
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )),
              ));
  }

  // void _getUserLocation() async {
  //   if (kIsWeb == true) {
  //     // await getCurrentPosition(allowInterop((pos) {
  //     //   setState(() {
  //     //     // _initialPosition = LatLng(pos.coords.latitude, pos.coords.longitude);
  //     //   });
  //     //   getAddress() async {
  //     //     var url = Uri.https('maps.googleapis.com', "/maps/api/geocode/json", {
  //     //       "latlng": "${pos.coords.latitude},${pos.coords.longitude}",
  //     //       "key": "AIzaSyD28o_G3q1njuEc-LF3KT7dCMOT3Dj_Y7U"
  //     //     });
  //     //     var response = await http.get(url);
  //     //     print(url);
  //     //     // print("$lat,$lng");
  //     //     Map values = jsonDecode(response.body);
  //     //     List tempAdd = [];
  //     //     for (var i = 0;
  //     //         i < values["results"][0]["address_components"].length;
  //     //         i++) {
  //     //       tempAdd.add(
  //     //           values["results"][0]["address_components"][i]['long_name']);
  //     //     }
  //     //     String address = tempAdd.join(',');
  //     //     print(address);
  //     //     pickupAddress.text = address;
  //     //   }

  //     //   getAddress();
  //     // }));
  //   } else {
  //     Position position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high);
  //     List<Placemark> placemark =
  //         await placemarkFromCoordinates(position.latitude, position.longitude);
  //     setState(() {
  //       // _initialPosition = LatLng(position.latitude, position.longitude);
  //       area.text =
  //           "${placemark[0].name}, ${placemark[0].subAdministrativeArea}, ${placemark[0].administrativeArea}, ${placemark[0].postalCode}";
  //     });
  //     print(placemark[0]);
  //   }
  // }

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
}
