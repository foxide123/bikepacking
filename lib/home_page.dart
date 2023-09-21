import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text("AUTHENTICATE"),
          onPressed: authenticate,
        ),
      ),
    );
  }
}

Future<void> authenticate() async {
  final clientId = "114033";
  final redirectUri = "https://foxide123.github.io";
  //final redirectUri = "https://localhost:8080";
  final responseType = "code";
  final approvalPrompt = "auto";
  final scope = "activity:write,read";

  final uri = Uri.https(
    "www.strava.com",
    "/oauth/mobile/authorize",
    {
      "client_id": clientId,
      "redirect_uri": redirectUri,
      "response_type": responseType,
      "approval_prompt": approvalPrompt,
      "scope": scope,
    },
  );
  if (await canLaunchUrl(Uri.parse(uri.toString()))) {
    await launchUrl(Uri.parse(uri.toString()));
  } else {
    print("Could not launch $uri");
  }
}
