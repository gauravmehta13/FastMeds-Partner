import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService(this.uid);
  final CollectionReference userInfo =
      FirebaseFirestore.instance.collection("Shops");

  Future updateUserData(String shopName, String gstNo, String address,
      String city, String state, String phone) async {
    await userInfo.doc(uid).set({
      'shopName': shopName,
      'phone': phone,
      'city': city,
      'state': state,
      'address': address,
      "gstNo": gstNo,
    });
  }
}
