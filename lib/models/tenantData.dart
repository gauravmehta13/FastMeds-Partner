import 'package:cloud_firestore/cloud_firestore.dart';

class TenantDetails {
  late String tenant;
  TenantDetails.fromMap(DocumentSnapshot<Object?> data) {
    tenant = data['tenant'];
  }
}

class PharmacyDetails {
  late String pharmacyName;
  late String phone;
  late String pin;
  late String po;
  late String block;
  late String city;
  late String state;
  late String address;
  late String imgUrl;
  late String email;
  late String photoUrl;
  late String name;

  PharmacyDetails.fromMap(DocumentSnapshot<Object?> data) {
    pharmacyName = data['pharmacyName'];
    phone = data['phone'];
    pin = data["pin"];
    po = data['postOffice'];
    block = data['block'];
    city = data['city'];
    state = data['state'];
    address = data['address'];
    imgUrl = data["imgUrl"];
    email = data["email"];
    photoUrl = data["photo"];
    name = data["name"];
  }
}
