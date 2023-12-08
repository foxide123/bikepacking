import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BikepackingListPage extends StatefulWidget {
  const BikepackingListPage({super.key});

  @override
  State<BikepackingListPage> createState() => _BikepackingListPageState();
}

class _BikepackingListPageState extends State<BikepackingListPage> {

  TextEditingController? textEditingController;

  @override
  void initState() {
    textEditingController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff975a28),
      appBar: AppBar(),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/bike.png", height: 150),
            Text("Bike list", style: GoogleFonts.aclonica(textStyle: TextStyle(fontSize: 20,fontStyle: FontStyle.italic))),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "Add new item",
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16.0,
                            color: Colors.black,
                          )
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}