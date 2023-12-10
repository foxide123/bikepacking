import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class BikepackingListCategoryWidget extends StatefulWidget {
  final String title;
  final String image;
  final VoidCallback onTap;
  final bool isExpanded;
  const BikepackingListCategoryWidget(
      {required this.title,
      required this.image,
      required this.onTap,
      this.isExpanded = false,
      super.key});

  @override
  State<BikepackingListCategoryWidget> createState() =>
      _BikepackingListCategoryWidgetState();
}

class _BikepackingListCategoryWidgetState
    extends State<BikepackingListCategoryWidget> {
  List<String> clothes = [];
  TextEditingController controller = TextEditingController();
  bool animationFinished = false;

  void handleTap() {
    if (!widget.isExpanded) {
      setState(() {
        animationFinished = false;
      });
    }
    widget.onTap();
    afterAnimation();
  }

  void afterAnimation() async {
    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {
        animationFinished = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: handleTap,
      child: AnimatedContainer(
        //onEnd: () => afterAnimation(),
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Color(0xfffff3d1),
          borderRadius: BorderRadius.circular(10),
        ),
        width: widget.isExpanded ? 400 : 170,
        height: widget.isExpanded ? 300 : 140,
        child: Column(
          mainAxisAlignment: widget.isExpanded
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Image.asset(
              widget.image,
              height: 100,
            ),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.aclonica(
                textStyle: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            widget.isExpanded && animationFinished
                ? TextField(
                    onSubmitted: (value) async {
                      setState(() {
                        clothes.add(value);
                      });
                      controller.value = TextEditingValue.empty;
                    },
                    controller: controller,
                    decoration: const InputDecoration(
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
                  )
                : SizedBox(),
            widget.isExpanded && animationFinished
                ? SizedBox(height: 30)
                : SizedBox(),
            widget.isExpanded && animationFinished
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: clothes.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(border: Border.all()),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8.0,8.0,8.0,8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  clothes[index],
                                  style: GoogleFonts.aclonica(
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                                Icon(FontAwesomeIcons.x),
                              ],
                            ),
                          ),
                        ),
                      );
                    })
                : SizedBox(),
          ],
        ),
      ),
    );
    /*return Container(
                  height: 140,
                  width: 170,
                  decoration: BoxDecoration(
                    color: Color(0xfffff3d1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        widget.image,
                        height: 100,
                      ),
                      Text(widget.title, textAlign: TextAlign.center,
                      style: GoogleFonts.aclonica(textStyle: TextStyle(fontSize: 16,fontStyle: FontStyle.italic)))
                    ],
                  ),
                );*/
  }
}
