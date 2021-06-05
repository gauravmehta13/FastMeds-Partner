import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ProgressBar.dart';

PreferredSizeWidget? myAppBar(step, title, context) {
  return PreferredSize(
    preferredSize: Size.fromHeight(AppBar().preferredSize.height),
    child: AppBar(
      elevation: 1,
      title: Text(
        title,
        style:
            GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      centerTitle: true,
      actions: [IconButton(onPressed: () {}, icon: Icon(Icons.help_outline))],
      bottom: PreferredSize(
        preferredSize: Size(double.infinity, 10.0),
        child: StepProgressView(
            width: MediaQuery.of(context).size.width,
            curStep: step,
            color: Color(0xFFf9a825),
            titles: ["", "", "", "", ""]),
      ),
    ),
  );
}
