import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fastmeds/Constants/Constants.dart';
import 'package:fastmeds/Screens/Pharmacy/Onboarding/DrugList.dart';
import 'package:fastmeds/Widgets/Loading.dart';
import 'package:fastmeds/Widgets/Progress%20Appbar.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

import 'package:location/location.dart';

import 'package:syncfusion_flutter_maps/maps.dart';

import '../../../Fade Route.dart';

class Address extends StatefulWidget {
  @override
  _AddressState createState() => _AddressState();
}

class _AddressState extends State<Address> {
  Location location = new Location();
  late double latitude = 0;
  late double longitude = 0;
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  final _formKey = GlobalKey<FormState>();

  var area = new TextEditingController();
  var pin = new TextEditingController();
  var city = new TextEditingController();
  var state = new TextEditingController();
  var streetAddress = new TextEditingController();

  late List<dynamic> searchResults = [];
  late List<dynamic> pinResults = [];

  late String lat;
  late String lng;

  var address = new TextEditingController();
  var dio = Dio();
  final geo = Geoflutterfire();

  late MapZoomPanBehavior _zoomPanBehavior;
  late MapTileLayerController _controller;
  bool gettingPin = false;
  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _zoomPanBehavior = MapZoomPanBehavior(enableDoubleTapZooming: true);
    _controller = MapTileLayerController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
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
              onPressed: () async {
                GeoFirePoint myLocation =
                    geo.point(latitude: latitude, longitude: longitude);
                print(myLocation.data.toString());
                Navigator.push(
                  context,
                  FadeRoute(page: DrugList()),
                );
              },
              child: Text(
                "Next",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
        appBar: myAppBar(3, "Pharmacy Registration", context),
        body: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: SafeArea(
                    child: Container(
                        padding: EdgeInsets.all(5),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              box20,
                              Container(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Address Details",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: Colors.grey,
                                          width: 1,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      child: Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (latitude != 0)
                                              longitude == 0
                                                  ? Container(
                                                      height: 300,
                                                      child: Loading())
                                                  : SfMaps(
                                                      layers: [
                                                        MapTileLayer(
                                                          urlTemplate:
                                                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                          initialZoomLevel: 10,
                                                          initialFocalLatLng:
                                                              MapLatLng(
                                                                  latitude,
                                                                  longitude),
                                                          initialMarkersCount:
                                                              5,
                                                          markerBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int index) {
                                                            return MapMarker(
                                                              latitude:
                                                                  latitude,
                                                              longitude:
                                                                  longitude,
                                                              child: Icon(
                                                                Icons
                                                                    .add_location,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            );
                                                          },
                                                          controller:
                                                              _controller,
                                                          zoomPanBehavior:
                                                              _zoomPanBehavior,
                                                        ),
                                                      ],
                                                    ),
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              child: Column(
                                                children: [
                                                  box10,
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField(
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
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom:
                                                                      150.0),
                                                          controller: address,
                                                          onChanged: (value) {
                                                            search(value);
                                                          },
                                                          decoration:
                                                              addressTextfieldDecoration(
                                                                  "Area / Colony",
                                                                  "Search Area"),
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Expanded(
                                                        child: TextFormField(
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
                                                          controller: pin,
                                                          onChanged:
                                                              (pin) async {
                                                            var value =
                                                                int.tryParse(
                                                                    pin);
                                                            var count = 0,
                                                                temp = value;
                                                            while (temp! > 0) {
                                                              count++;
                                                              temp = (temp / 10)
                                                                  .floor();
                                                            }
                                                            print(count);

                                                            if (count == 6) {
                                                              setState(() {
                                                                gettingPin =
                                                                    true;
                                                              });
                                                              searchPin(pin);
                                                            }
                                                          },
                                                          scrollPadding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom:
                                                                      150.0),
                                                          maxLength: 6,
                                                          decoration:
                                                              InputDecoration(
                                                            suffix: gettingPin
                                                                ? SizedBox(
                                                                    height: 20,
                                                                    width: 20,
                                                                    child:
                                                                        CircularProgressIndicator())
                                                                : SizedBox
                                                                    .shrink(),
                                                            isDense: true,
                                                            counterText: "",
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    15),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(Radius
                                                                          .circular(
                                                                              4)),
                                                              borderSide:
                                                                  BorderSide(
                                                                width: 1,
                                                                color: Color(
                                                                    0xFF2821B5),
                                                              ),
                                                            ),
                                                            border: new OutlineInputBorder(
                                                                borderSide: new BorderSide(
                                                                    color: Colors
                                                                        .grey)),
                                                            labelText:
                                                                "Pin Code",
                                                          ),
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (pinResults != null &&
                                                      pinResults.length != 0)
                                                    getSuggestions(
                                                        pinResults, ""),
                                                  if (searchResults.length != 0)
                                                    getSuggestions(
                                                        searchResults, ""),
                                                  box20,
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField(
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
                                                          controller: city,
                                                          scrollPadding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom:
                                                                      150.0),
                                                          decoration:
                                                              addressTextfieldDecoration(
                                                                  "Town / City",
                                                                  ""),
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Expanded(
                                                        child: TextFormField(
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
                                                          controller: state,
                                                          scrollPadding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom:
                                                                      150.0),
                                                          decoration:
                                                              addressTextfieldDecoration(
                                                                  "State", ""),
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      box20,
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
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 150.0),
                                                        controller:
                                                            streetAddress,
                                                        decoration: addressTextfieldDecoration(
                                                            "Enter Street Address",
                                                            'Flat, House No., Building, Company, Apartment'),
                                                        textInputAction:
                                                            TextInputAction
                                                                .next,
                                                      ),
                                                    ],
                                                  ),
                                                  box10,
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]))
                            ]))))));
  }

  Widget getSuggestions(List suggestions, String type) {
    return Container(
      height: 200,
      child: ListView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: new BoxDecoration(
                  border: new Border(
                      bottom: new BorderSide(color: Colors.grey[100]!))),
              child: ListTile(
                dense: true,
                title: Text(
                  suggestions[index]["Name"],
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  getLatLng(suggestions[index]["Pincode"]);

                  FocusScope.of(context).unfocus();

                  setState(() {
                    address.text = suggestions[index]["Name"];
                    pin.text = suggestions[index]["Pincode"];
                    city.text = suggestions[index]["Division"];
                    state.text = suggestions[index]["State"];
                  });

                  print(suggestions[index]);
                  setState(() {
                    suggestions = [];
                    pinResults = [];
                    searchResults = [];
                  });
                },
              ),
            );
          }),
    );
  }

  void _getUserLocation() async {
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
    print(_locationData.latitude.toString());
    print(_locationData.longitude.toString());
    setState(() {
      latitude = _locationData.latitude!;
      longitude = _locationData.longitude!;
      lat = _locationData.latitude.toString();
      lng = _locationData.longitude.toString();
    });
    getCity(lat.toString(), lng.toString());
  }

  getLatLng(pin) async {
    setState(() {
      longitude = 0;
    });
    final resp = await dio.get(
        "https://nominatim.openstreetmap.org/search?format=json&postalcode=$pin&country=india");
    print(resp.data);
    var map = resp.data[0];
    setState(() {
      latitude = double.tryParse(map["lat"])!;
      longitude = double.tryParse(map["lon"])!;
    });
    print(latitude);
  }

  getCity(lat, lon) async {
    final resp = await dio.get(
        "https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon");
    print(resp.data);
    setState(() {
      address.text = resp.data["address"]["county"];
      pin.text = resp.data["address"]["postcode"];
      city.text = resp.data["address"]["state_district"];
      state.text = resp.data["address"]["state"];
    });
  }

  Future<List<dynamic>> getAreaData(String search) async {
    final response = await dio.get(
      "https://api.postalpincode.in/postoffice/$search",
    );
    print(response.data);
    var map = response.data[0]["PostOffice"];

    print(map);
    return map;
  }

  Future<List<dynamic>> getPinData(pin) async {
    FocusScope.of(context).unfocus();
    var response = await dio.get("https://api.postalpincode.in/pincode/$pin");
    print(response.data);
    var data = response.data;
    return data[0]["PostOffice"];
  }

  search(String searchTerm) async {
    searchResults = await getAreaData(searchTerm);
    setState(() {
      searchResults = searchResults;
    });
    print(searchResults);
  }

  searchPin(String pin) async {
    pinResults = await getPinData(pin);
    setState(() {
      pinResults = pinResults;
      gettingPin = false;
    });
    print(pinResults);
  }
}
