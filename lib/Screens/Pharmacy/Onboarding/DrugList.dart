import 'dart:convert';
import 'package:fastmeds/Widgets/Loading.dart';
import 'package:fastmeds/Widgets/Progress%20Appbar.dart';
import 'package:flutter/material.dart';

class MedList {
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

class DrugList extends StatefulWidget {
  const DrugList({Key? key}) : super(key: key);

  @override
  _DrugListState createState() => _DrugListState();
}

class _DrugListState extends State<DrugList> {
  bool loading = true;
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await loadJson();
    });
  }

  List<MedList> medList = [];

  loadJson() async {
    String data =
        await DefaultAssetBundle.of(context).loadString("assets/med.json");

    setState(() {
      //medList = json.decode(data);
      medList =
          (json.decode(data) as List).map((d) => MedList.fromJson(d)).toList();
      loading = false;
    });
    print(medList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(4, "Pharmacy Registration", context),
      body: loading
          ? Loading()
          : Container(
              child: Autocomplete<MedList>(
                displayStringForOption: (option) => option.brand,
                fieldViewBuilder: (context, textEditingController, focusNode,
                        onFieldSubmitted) =>
                    TextField(
                  scrollPadding: const EdgeInsets.only(bottom: 150.0),
                  controller: textEditingController,
                  onTap: () {
                    textEditingController.clear();
                  },
                  focusNode: focusNode,
                  // onEditingComplete: onFieldSubmitted,
                  decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      hintText: "Search District"),
                ),
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text == '') {
                    return medList;
                  }
                  return medList.where((s) {
                    return s.brand
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (selection) {
                  final FocusScopeNode currentScope = FocusScope.of(context);
                  if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                    FocusManager.instance.primaryFocus!.unfocus();
                  }
                },
              ),
            ),
    );
  }
}
