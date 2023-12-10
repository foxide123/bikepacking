import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotebookPage extends StatelessWidget {
  const NotebookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/notebook.png'),
                    fit: BoxFit.cover)),
          ),
          Positioned.fill(
            top: 10,
            child: Align(
              alignment: Alignment.topCenter,
              child: Text("01-10-2020",
                  style: GoogleFonts.aclonica(
                      textStyle:
                          TextStyle(fontSize: 30, fontStyle: FontStyle.italic))),
            ),
          ),
          Positioned(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/wallpaper.png', height: 100, width: 100),
                  Container(
                      width: MediaQuery.of(context).size.width - 100,
                      child: Text(
                          "Yo yo yo. This is my amazing journal from todays trip",
                          style: GoogleFonts.aclonica(
                              textStyle: TextStyle(
                                  fontSize: 20, fontStyle: FontStyle.italic)))),
                ],
              ),
              top: 100,
              left: 40),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text("ADD"),
            ),
            bottom: 150,
          ),
        ],
      ),
    );
  }
}
