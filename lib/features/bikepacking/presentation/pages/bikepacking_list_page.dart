import 'package:bikepacking/features/bikepacking/presentation/widgets/bikepacking_list_category_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BikepackingListPage extends StatefulWidget {
  const BikepackingListPage({super.key});

  @override
  State<BikepackingListPage> createState() => _BikepackingListPageState();
}

class _BikepackingListPageState extends State<BikepackingListPage> {
  TextEditingController? textEditingController;
  int? selectedItemId;

  @override
  void initState() {
    textEditingController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    List<String> itemTitles = ['Clothing', 'Camping', 'Cooking gear', 'Emergency'];
   List<Widget> items = [
      // Add your BikepackingListCategoryWidget items here
      // Wrap each widget with AnimatedSize
      for (int i = 0; i < 4; i++)
        AnimatedSize(
          duration: Duration(milliseconds: 2000),
          curve: Curves.easeInOut,
          child: Container(
            width: selectedItemId == i ? 400:170,
            child: BikepackingListCategoryWidget(
              image: "assets/image_$i.png",
              title: itemTitles[i],
              onTap: () {
                setState(() {
                  selectedItemId = selectedItemId == i ? null : i;
                });
              },
              isExpanded: selectedItemId == i,
            ),
          ),
        ),
    ];

    return Scaffold(
      backgroundColor: Color(0xff975a28),
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Image.asset("assets/bikepacking_items.png", height: 220),
            Text("Bike list",
                style: GoogleFonts.aclonica(
                    textStyle:
                        TextStyle(fontSize: 20, fontStyle: FontStyle.italic))),
            const TextField(
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "Add new item",
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
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 4,
              runSpacing: 20,
              alignment: WrapAlignment.spaceEvenly,
              children: items
            ),
            SizedBox(height: 20),
            Container(
              height: 150,
              width: 300,
              decoration: BoxDecoration(
                color: Color(0xffffeabb),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Image.asset("assets/bike_with_bags.png",
                      height: 120, width: 200),
                  Text("Bags",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.aclonica(
                          textStyle: TextStyle(
                              fontSize: 20, fontStyle: FontStyle.italic)))
                ],
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BikepackingListCategoryWidget(
                    image: "assets/retro_food.png", title: "Food",
                    onTap: () {
                    setState(() {
                      selectedItemId =
                          selectedItemId == 6 ? null : 6; // Toggle expansion
                    });
                  },
                  isExpanded: selectedItemId == 6,),
                BikepackingListCategoryWidget(
                    image: "assets/repair_tools.png", title: "Repair tools",
                    onTap: () {
                    setState(() {
                      selectedItemId =
                          selectedItemId == 7 ? null : 7; // Toggle expansion
                    });
                  },
                  isExpanded: selectedItemId == 7,),
              ],
            ),
            SizedBox(height: 30),

            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: Color(0xfffff3d1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                "assets/hygiene_products.png",
                height: 50,
              ),
            )
          ],
        ),
      ),
    );
  }
}
