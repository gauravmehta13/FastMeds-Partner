import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService(this.uid);

  Future updateUserData(String tenant) async {
    await FirebaseFirestore.instance.collection("Tenant").doc(uid).set({
      'tenant': tenant,
    });
  }

  Future updatePharmacyData(
      String pharmacyName,
      String phone,
      String pin,
      String po,
      String block,
      String city,
      String state,
      String address,
      String imgUrl,
      String email,
      String photoUrl,
      String name,
      var position,
      double long,
      double lat) async {
    await FirebaseFirestore.instance.collection("Pharmacy").doc(uid).set({
      'pharmacyName': pharmacyName,
      'phone': phone,
      'city': city,
      'state': state,
      'block': block,
      'postOffice': po,
      'address': address,
      "pin": pin,
      "imgUrl": imgUrl,
      "email": email,
      "photo": photoUrl,
      "name": name,
      'position': position,
      'lat': lat,
      'long': long
    });
  }

  Future updateHospitalsData(String shopName, String gstNo, String address,
      String city, String state, String phone) async {
    await FirebaseFirestore.instance.collection("Hospitals").doc(uid).set({
      'shopName': shopName,
      'phone': phone,
      'city': city,
      'state': state,
      'address': address,
      "gstNo": gstNo,
    });
  }

  Future updateDoctorsData(String shopName, String gstNo, String address,
      String city, String state, String phone) async {
    await FirebaseFirestore.instance.collection("Doctors").doc(uid).set({
      'shopName': shopName,
      'phone': phone,
      'city': city,
      'state': state,
      'address': address,
      "gstNo": gstNo,
    });
  }

  Future updateVolunteersData(String shopName, String gstNo, String address,
      String city, String state, String phone) async {
    await FirebaseFirestore.instance.collection("Volunteers").doc(uid).set({
      'shopName': shopName,
      'phone': phone,
      'city': city,
      'state': state,
      'address': address,
      "gstNo": gstNo,
    });
  }

  Future updateAmbulanceData(String shopName, String gstNo, String address,
      String city, String state, String phone) async {
    await FirebaseFirestore.instance.collection("Ambulance").doc(uid).set({
      'shopName': shopName,
      'phone': phone,
      'city': city,
      'state': state,
      'address': address,
      "gstNo": gstNo,
    });
  }

  Future updateDiagnoticLabsData(String shopName, String gstNo, String address,
      String city, String state, String phone) async {
    await FirebaseFirestore.instance.collection("DiagnoticLabs").doc(uid).set({
      'shopName': shopName,
      'phone': phone,
      'city': city,
      'state': state,
      'address': address,
      "gstNo": gstNo,
    });
  }
}
