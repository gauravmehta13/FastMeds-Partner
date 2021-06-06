import 'dart:convert';
import 'package:fastmeds/Constants/Constants.dart';
import 'package:fastmeds/Widgets/Loading.dart';
import 'package:fastmeds/Widgets/Progress%20Appbar.dart';
import 'package:fastmeds/models/Drugs%20Model.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

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
  List<MedList> filteredMedList = [];
  List<MedList> addedMeds = [];

  loadJson() async {
    String data =
        await DefaultAssetBundle.of(context).loadString("assets/med.json");

    setState(() {
      medList =
          (json.decode(data) as List).map((d) => MedList.fromJson(d)).toList();
      filteredMedList = medList;
      loading = false;
    });
    print(medList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(4, "Pharmacy Registration", context),
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
            onPressed: () async {},
            child: Text(
              "Next",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
      body: loading
          ? Loading()
          : SingleChildScrollView(
              child: Column(
                children: [
                  box10,
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: new TextFormField(
                      textInputAction: TextInputAction.go,
                      onChanged: (string) {
                        setState(() {
                          filteredMedList = (medList)
                              .where((u) => (u.brand
                                      .toString()
                                      .toLowerCase()
                                      .contains(string.toLowerCase()) ||
                                  u.company
                                      .toString()
                                      .toLowerCase()
                                      .contains(string.toLowerCase())))
                              .toList();
                        });
                      },
                      keyboardType: TextInputType.text,
                      decoration: new InputDecoration(
                        isDense: true, // Added this
                        contentPadding: EdgeInsets.all(15),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            width: 1,
                            color: Color(0xFF2821B5),
                          ),
                        ),
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.grey)),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.search,
                            color: Colors.black,
                          ),
                        ),
                        hintText: "Search..",
                      ),
                    ),
                  ),
                  box20,
                  Container(
                    height: MediaQuery.of(context).size.height,
                    child: GroupedListView<MedList, String>(
                      shrinkWrap: true,
                      elements: filteredMedList,
                      groupBy: (element) => element.package,
                      groupComparator: (value1, value2) =>
                          value2.compareTo(value1),
                      // itemComparator: (item1, item2) =>
                      //     item2.name.compareTo(item1.name),
                      // optional
                      // useStickyGroupSeparators: true, // optional
                      // floatingHeader: true, // optional
                      order: GroupedListOrder.DESC,
                      groupSeparatorBuilder: (String value) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          value,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      itemBuilder: (c, element) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              element.selected = !element.selected;
                            });
                          },
                          child: Card(
                            color: element.selected
                                ? Colors.green.withOpacity(0.3)
                                : Colors.white,
                            shape: Border(
                                bottom:
                                    BorderSide(color: Colors.grey, width: 1)),
                            elevation: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                bottom: BorderSide(
                                  //                    <--- top side
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                              )),
                              padding: EdgeInsets.all(10),
                              child: Row(children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Image.asset(
                                  "assets/pills.png",
                                  height: 50,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  flex: 10,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        element.brand,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      box10,
                                      Text(
                                        element.company,
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Column(
                                  children: [
                                    Text(
                                      "₹ ${element.price}",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                    box10,
                                    Text(
                                      element.strength,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 80,
                  ),
                ],
              ),
            ),
    );
  }
}
