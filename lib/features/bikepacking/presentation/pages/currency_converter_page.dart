import 'package:bikepacking/features/bikepacking/data/datasources/api_client.dart';
import 'package:bikepacking/features/bikepacking/presentation/widgets/drop_down.dart';
import 'package:flutter/material.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  List<String> currencies = [];
  String from = "";
  String to = "";

  double rate = 0;
  String result = "";

  ApiClient client = ApiClient();

  void getCurrencyList() async {
    List<String> temp = await client.getCurrencies();
    setState(() {
      currencies = temp;
    });
  }

  @override
  void initState() {
    getCurrencyList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff975a28),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/bike_scenery.png", height: 200),
                  //Image.asset("assets/retro_bike.png", height: 200,),
                  TextField(
                    onSubmitted: (value) async{
                      rate = await client.getRate(from, to);
                      setState(() {
                        result = (rate* double.parse(value)).toStringAsFixed(3);
                      });
                    },
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Input value to convert",
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16.0,
                          color: Colors.black,
                        )),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      customDropDown(currencies, from, (val) {
                        setState(() {
                          from = val!;
                        });
                      }),
                      FloatingActionButton(
                        onPressed: () {
                          String temp = from;
                          setState(() {
                            from = to;
                            to = temp;
                          });
                        },
                        child: Icon(Icons.swap_horiz),
                        elevation: 0.0,
                        backgroundColor: Colors.blue,
                      ),
                      customDropDown(currencies, to, (val) {
                        setState(() {
                          to = val!;
                        });
                      }),
                    ],
                  ),
                  SizedBox(height: 50.0),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(children: [
                      Text("Result",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          )),
                      Text(result,
                          style: TextStyle(
                            fontSize: 36.0,
                            fontWeight: FontWeight.bold,
                          )),
                    ]),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
