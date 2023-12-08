import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BikepackingPage extends StatelessWidget {
  const BikepackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 100),
          Row(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00BA704F),
                        Color(0xff975a28),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Image.asset("assets/currency_converter.png", height: 150),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20.0,0,0,0),
                        child: Text("Currency converter", style: GoogleFonts.aclonica(textStyle: TextStyle(fontSize: 20,fontStyle: FontStyle.italic))),
                      ),
                    ],
                  ),
                ),
                onTap: ()=> GoRouter.of(context).push("/currencyConverterPage"),
              ),
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00BA704F),
                        Color(0xff975a28),
                      ],
                    ),
                  ),
                  child: Flexible(
                    child: Column(
                      children: [
                        Image.asset("assets/first_aid_kit.png", height: 150),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0,0,0,0),
                          child: Text("First Aid Tutorials", style: GoogleFonts.aclonica(textStyle: TextStyle(fontSize: 20,fontStyle: FontStyle.italic))),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
 GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 200,
                  decoration: const BoxDecoration(
                   color: Color(0xff975a28)
                  ),
                  child: Flexible(
                    child: Column(
                      children: [
                        Image.asset("assets/bikepacking_list.png", height: 150),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0,0,0,0),
                          child: Text("First Aid Tutorials", style: GoogleFonts.aclonica(textStyle: TextStyle(fontSize: 20,fontStyle: FontStyle.italic))),
                        )
                      ],
                    ),
                  ),
                ),
               
              ),
               GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 200,
                  decoration: const BoxDecoration(
                   color: Color(0xff975a28)
                  ),
                  child: Flexible(
                    child: Column(
                      children: [
                        Image.asset("assets/bikepacking_list.png", height: 150),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0,0,0,0),
                          child: Text("Bikepacking list", style: GoogleFonts.aclonica(textStyle: TextStyle(fontSize: 20,fontStyle: FontStyle.italic))),
                        )
                      ],
                    ),
                  ),
                ),
                 onTap: ()=> GoRouter.of(context).push("/bikepackingListPage"),
              ),
            ],
          )
         
        ],
      ),
    );
  }
}
