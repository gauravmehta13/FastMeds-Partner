import 'package:fastmeds/Constants/Constants.dart';
import 'package:fastmeds/Constants/Districts.dart';
import 'package:fastmeds/Screens/Home%20Page.dart';
import 'package:fastmeds/models/database.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert' as convert;
import '../../Fade Route.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class MandatoryKYC extends StatefulWidget {
  final edit;
  MandatoryKYC({this.edit});
  @override
  _MandatoryKYCState createState() => _MandatoryKYCState();
}

class _MandatoryKYCState extends State<MandatoryKYC> {
  var dio = Dio();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  bool sendingData = false;
  bool kycCompleted = false;
  String districtName = "";
  String stateName = "";
  List<StateDistrictMapping> districtMapping = [];
  final formKey = GlobalKey<FormState>();
  var companyName = new TextEditingController();
  var streetAddress = new TextEditingController();
  var gstNo = new TextEditingController();
  var phone = new TextEditingController();

  // PlatformFile displayImage;
  // String displayImageLink;
  // PlatformFile incorporationCertificate;
  // String incorporationCertificateLink;
  // List<PlatformFile> otherImages = [];
  List<String> otherImagesLink = [];
  bool uploadingImages = false;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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
              onPressed: loading == true || uploadingImages == true
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          sendingData = true;
                        });
                        await DatabaseService(_auth.currentUser!.uid)
                            .updateUserData(
                                companyName.text,
                                gstNo.text,
                                streetAddress.text,
                                districtName,
                                stateName,
                                phone.text);
                        setState(() {
                          sendingData = false;
                        });
                        Navigator.pushReplacement(
                          context,
                          FadeRoute(page: HomeScreen()),
                        );
                      }
                    },
              child: sendingData == true || uploadingImages == true
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
                                          "85% customers prefer to select a Shopkeeper with a complete profile.",
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
                                      new TextFormField(
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        controller: gstNo,
                                        decoration: new InputDecoration(
                                            isDense: true, // Added this
                                            prefixIcon:
                                                Icon(FontAwesomeIcons.pen),
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
                                            labelText: "GST Number (Optional)"),
                                      ),
                                      box20,
                                      Row(
                                        children: [
                                          Text(
                                            "Shop Images :\n(Optional)",
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          RawMaterialButton(
                                              onPressed: () {},
                                              elevation: 0,
                                              fillColor: Color(0xFFf9a825)
                                                  .withOpacity(0.3),
                                              child:
                                                  Icon(FontAwesomeIcons.upload),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
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

  // getIncorporationCertificate() async {
  //   FilePickerResult result = await FilePicker.platform.pickFiles(
  //     withReadStream: true,
  //     allowedExtensions: ['jpg', 'pdf', 'doc'],
  //     type: FileType.custom,
  //   );
  //   if (result != null) {
  //     print(result);
  //     print(result.files);
  //     print(result.files.single);
  //     print(result.files.single.name);
  //     print(result.files.single.size);
  //     print(result.files.single.path);
  //     setState(() {
  //       // print(paths.first.extension);
  //       // fileName = paths != null ? paths.map((e) => e.name).toString() : '...';
  //       // print(fileName);
  //     });
  //     setState(() {
  //       incorporationCertificate = result.files.single;
  //     });
  //     uploadIncorpCertificate();
  //   } else {
  //     // User canceled the picker
  //   }
  // }

  // getDisplayImage() async {
  //   FilePickerResult result = await FilePicker.platform.pickFiles(
  //     withReadStream: true,
  //     allowedExtensions: ["jpg"],
  //     type: FileType.custom,
  //   );
  //   if (result != null) {
  //     setState(() {
  //       displayImage = result.files.single;
  //     });
  //     uploadDisplayImage();
  //   } else {
  //     // User canceled the picker
  //   }
  // }

  // getOtherImages() async {
  //   try {
  //     otherImages = (await FilePicker.platform.pickFiles(
  //       withReadStream: true,
  //       allowMultiple: true,
  //       allowedExtensions: ["jpg"],
  //       type: FileType.custom,
  //     ))
  //         ?.files;
  //     setState(() {
  //       otherImages = otherImages;
  //     });
  //     print(otherImages.length);
  //     uploadOtherImages();
  //   } on PlatformException catch (e) {
  //     print("Unsupported operation" + e.toString());
  //   } catch (ex) {
  //     print(ex);
  //   }
  // }

  // uploadIncorpCertificate() async {
  //   setState(() {
  //     uploadingImages = true;
  //   });
  //   final mimeType = lookupMimeType(incorporationCertificate.name);
  //   print(mimeType);

  //   await dio.post(
  //       'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/document?type=packersAndMovers',
  //       data: {
  //         "contentType": mimeType,
  //         "metaData": {
  //           "contentType": mimeType,
  //         },
  //       }).then((response) async {
  //     Map<String, dynamic> map = json.decode(response.toString());

  //     setState(() {
  //       incorporationCertificateLink = map['key'];
  //     });
  //     print(incorporationCertificateLink);

  //     dio.put(
  //       map['s3PutObjectUrl'],
  //       data: incorporationCertificate.readStream,
  //       options: Options(
  //         contentType: mimeType,
  //         headers: {"Content-Length": incorporationCertificate.size},
  //       ),
  //       onSendProgress: (int sentBytes, int totalBytes) {
  //         double progressPercent = sentBytes / totalBytes * 100;
  //         print("$progressPercent %");
  //       },
  //     ).then((response) {
  //       print(response);
  //       print(response.statusCode);
  //       dio.post(
  //           'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/info?type=packersAndMoversSP',
  //           data: {
  //             "type": "packersAndMoversSP",
  //             "id": _auth.currentUser.uid,
  //             "mobile": _auth.currentUser.phoneNumber,
  //             "tenantUsecase": "pam",
  //             "tenantSet_id": "PAM01",
  //             "incorporationCertificate":
  //                 incorporationCertificateLink.toString()
  //           }).then((response) {
  //         print(response);
  //         setState(() {
  //           uploadingImages = false;
  //         });
  //       });
  //     }).catchError((error) {
  //       setState(() {
  //         uploadingImages = false;
  //       });
  //       print(error);
  //     });
  //   });
  // }

  // uploadDisplayImage() async {
  //   setState(() {
  //     uploadingImages = true;
  //   });
  //   final mimeType = lookupMimeType(displayImage.name);
  //   await dio.post(
  //       'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/document?type=packersAndMovers',
  //       data: {
  //         "contentType": mimeType,
  //         "metaData": {
  //           "contentType": mimeType,
  //         },
  //       }).then((response) async {
  //     print(response);
  //     Map<String, dynamic> map = json.decode(response.toString());
  //     setState(() {
  //       displayImageLink = map['key'];
  //     });
  //     print(displayImageLink);
  //     print(mimeType);

  //     dio.put(
  //       map['s3PutObjectUrl'],
  //       data: displayImage.readStream,
  //       options: Options(
  //         contentType: mimeType,
  //         headers: {
  //           "Content-Length": displayImage.size,
  //         },
  //       ),
  //       onSendProgress: (int sentBytes, int totalBytes) {
  //         double progressPercent = sentBytes / totalBytes * 100;
  //         print("$progressPercent %");
  //       },
  //     ).then((response) {
  //       print(response);
  //       print(response.statusCode);
  //       dio.post(
  //           'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/info?type=packersAndMoversSP',
  //           data: {
  //             "type": "packersAndMoversSP",
  //             "id": _auth.currentUser.uid,
  //             "mobile": _auth.currentUser.phoneNumber,
  //             "tenantUsecase": "pam",
  //             "tenantSet_id": "PAM01",
  //             "displayImage": displayImageLink.toString()
  //           }).then((response) {
  //         print(response);
  //       });
  //       dio.post(
  //           'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/serviceprovidercost',
  //           data: {
  //             "serviceProviderId": _auth.currentUser.uid,
  //             "mobile": _auth.currentUser.phoneNumber,
  //             "tenantUsecase": "pam",
  //             "tenantSet_id": "PAM01",
  //             "selfInfo": {"displayImage": displayImageLink.toString()}
  //           }).then((value) => print(value));
  //       print(response);
  //       setState(() {
  //         uploadingImages = false;
  //       });
  //     }).catchError((error) {
  //       setState(() {
  //         uploadingImages = false;
  //       });
  //       print(error);
  //     });
  //   });
  // }

  // uploadOtherImages() async {
  //   for (var i = 0; i < otherImages.length; i++) {
  //     setState(() {
  //       uploadingImages = true;
  //     });
  //     final mimeType = lookupMimeType(otherImages[i].name);
  //     await dio.post(
  //         'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/document?type=packersAndMovers',
  //         data: {
  //           "contentType": mimeType,
  //           "metaData": {
  //             "contentType": mimeType,
  //           },
  //         }).then((response) async {
  //       print(response);
  //       Map<String, dynamic> map = json.decode(response.toString());
  //       setState(() {
  //         otherImagesLink.add(map['key']);
  //       });
  //       print(otherImagesLink[i]);
  //       dio.put(
  //         map['s3PutObjectUrl'],
  //         data: otherImages[i].readStream,
  //         options: Options(
  //           contentType: mimeType,
  //           headers: {
  //             "Content-Length": otherImages[i].size,
  //           },
  //         ),
  //         onSendProgress: (int sentBytes, int totalBytes) {
  //           double progressPercent = sentBytes / totalBytes * 100;
  //           print("$progressPercent %");
  //         },
  //       ).then((response) {
  //         print(response);

  //         print(response.statusCode);
  //         dio.post(
  //             'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/info?type=packersAndMoversSP',
  //             data: {
  //               "type": "packersAndMoversSP",
  //               "id": _auth.currentUser.uid,
  //               "mobile": _auth.currentUser.phoneNumber,
  //               "tenantUsecase": "pam",
  //               "tenantSet_id": "PAM01",
  //               "otherImages${i.toString()}": otherImagesLink[i].toString()
  //             }).then((response) {
  //           print(response);
  //           setState(() {
  //             uploadingImages = false;
  //           });
  //         });
  //       }).catchError((error) {
  //         setState(() {
  //           uploadingImages = false;
  //         });
  //         print(error);
  //       });
  //     });
  //   }
  // }
}
