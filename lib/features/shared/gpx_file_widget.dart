import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GpxFileWidget extends StatefulWidget {
  String name = "";

  GpxFileWidget({
    required this.name,
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
          Expanded(
            flex: 1,
            child: FaIcon(FontAwesomeIcons.bicycle)),
          Flexible(
            flex: 3,
            child: Column(
              children: [
                Text(widget.name),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
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
