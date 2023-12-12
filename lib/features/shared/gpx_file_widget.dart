import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GpxFileWidget extends StatefulWidget {
  String name = "";
  bool isMapDownloaded;

  GpxFileWidget({
    required this.name,
    required this.isMapDownloaded,
    super.key,
  });

  @override
  State<GpxFileWidget> createState() => _GpxFileWidgetState();
}

class _GpxFileWidgetState extends State<GpxFileWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          Expanded(flex: 1, child: Image.asset("assets/image_4.png", height: 50,)),
          Flexible(
            flex: 3,
            child: Column(
              children: [
                Text(widget.name, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          widget.isMapDownloaded ? SizedBox() : Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FaIcon(FontAwesomeIcons.map),
                FaIcon(FontAwesomeIcons.download),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
