import 'package:fastmeds/Widgets/Progress%20Appbar.dart';
import 'package:flutter/material.dart';

class DrugList extends StatefulWidget {
  const DrugList({Key? key}) : super(key: key);

  @override
  _DrugListState createState() => _DrugListState();
}

class _DrugListState extends State<DrugList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(4, "Pharmacy Registration", context),
    );
  }
}
