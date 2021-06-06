class MedList {
  bool selected = false;
  late String brand;
  late String company;
  late String package;
  late String strength;
  late String price;

  MedList(
      {required this.brand,
      required this.company,
      required this.package,
      required this.strength,
      required this.price});

  MedList.fromJson(Map<String, dynamic> json) {
    brand = json['Brand'];
    company = json['Company'];
    package = json['Package'];
    strength = json['Strength'];
    price = json['Price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Brand'] = this.brand;
    data['Company'] = this.company;
    data['Package'] = this.package;
    data['Strength'] = this.strength;
    data['Price'] = this.price;
    return data;
  }
}
